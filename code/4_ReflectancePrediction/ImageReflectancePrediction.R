library(corrplot)
library(dplyr)
library(tidyr)
library(ggplot2)
library(stringr)
library(terra)
library(sf)

# import model (change path here)
model_save_path = "Z:/Cen_Lab/Projects/Drone_radiometric_correction/全天建模实验/4SelectedBand模型"
load(file.path(model_save_path, "model_25Bands.RData"))
band4_MLR = TRUE

# import STS data (change path here)
Spec_ReadinPath = "Z:/Cen_Lab/Projects/Drone_radiometric_correction/全天建模实验/20240227全天动态监测/STS"
spec_df = read.csv(file.path(Spec_ReadinPath, "RefSpectral_all.csv"))
print(wavelength_pick)
print(band_name)


names(spec_df)[-1] = paste0("STS_", names(spec_df[-1]))
#spec_name = names(spec_df)[-1]
spec_name = c("STS_X721.6", "STS_X772.74", "STS_X800.13", "STS_X915.23")
wavelength_band = data.frame(wavelength = wavelength_pick,
                             band = band_name)


# import MS data
# folder_pick = 1

print(folder_pick)
#folder_list = list.files("Z:/Cen_Lab/Projects/Drone_radiometric_correction/阴阳图/多光谱/解压后/架次2")
MS_image_ReadinPath = file.path("Z:/Cen_Lab/Projects/Drone_radiometric_correction/阴阳图/多光谱/解压后/架次2")



# begin
WritePath = file.path(MS_image_ReadinPath, "/OUTPUT_MS_images_4SelectedBands_20240828")
if(dir.exists(WritePath)) unlink(WritePath, recursive=TRUE)
dir.create(WritePath)


files = list.files(path = MS_image_ReadinPath, pattern = ".tif")
#files = "08-47-11_474.tif"

MS_time_vector = str_split(files, "_")
MS_time = sapply(MS_time_vector, `[`, 1)
MS_time = gsub("-", ":", MS_time)

MS_time = as.POSIXct(MS_time, format = "%H:%M:%S")
spec_df$time = as.POSIXct(spec_df$time, format = "%H:%M:%S")


#### sort  spectral meter data
RefSpectral_pick = as.data.frame(matrix(nrow = 0, ncol = ncol(spec_df)-1))
names(RefSpectral_pick) = spec_name
spec_time = c()
for(i in 1:length(files)){
  print(files[i])
  abs_dff = abs(MS_time[i]- spec_df$time)
  
  #abs_dff = difftime(MS_time[i]- spec_df$time)
  
  index = which(abs_dff == min(abs_dff))
  #print(index)
  
  colmean = colMeans(spec_df[index, -1])
  to_add = t(as.data.frame(colmean))
  
  RefSpectral_pick= rbind(RefSpectral_pick, to_add)
  
  spec_time = c(spec_time, as.character(spec_df$time[index][1]))
}
RefSpectral_pick = cbind(STS_time=spec_time, RefSpectral_pick)
RefSpectral_pick$STS_time = as.POSIXct(RefSpectral_pick$STS_time)
rownames(RefSpectral_pick) = 1:nrow(RefSpectral_pick)

#MS_time[i]

bk = RefSpectral_pick


p = ggplot(RefSpectral_pick, aes(x=STS_time, y=STS_X632.99)) +
  geom_line( size = 1.1) + ggtitle("光谱仪DN值") +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5)) +
  theme_light(base_size = 15)
#theme(axis.text.x = element_text(angle = 90, vjust = 1, hjust=1))
p



###################################################################################################
if(FALSE){
  ### 余弦校正器校正 20240701
  
  solar = read.csv(file.path(Spec_ReadinPath, "太阳高度角_SYT.csv"), header = TRUE)
  solar$time = as.POSIXct(solar$time, format = "%H:%M:%S")
  
  angle = read.csv(file.path(Spec_ReadinPath,"多光谱pick", "raw_image", "picked_angle.csv"), header = TRUE)
  files
  
  
  RefSpectral_pick_adj = RefSpectral_pick
  for(i in 1:nrow(RefSpectral_pick_adj)){
    
    this_time = RefSpectral_pick_adj$STS_time[i]
    this_file = files[i]
    
    this_angle = angle[which(angle$name == this_file), ]
    
    x_STS = this_angle$azimuth
    
    SolarAzimuth = solar[which(solar$time == this_time), "SolarAzimuth"]
    SolarAltitude = solar[which(solar$time == this_time), "SolarAltitude"]
    
    x_pre = x_STS - 180 - SolarAzimuth
    y_pre = (5.7*cos(SolarAltitude/180*pi)) * sin(x_pre*pi/180 -15.8*pi/180) / 100
    
    RefSpectral_pick_adj[i, -1] = RefSpectral_pick_adj[i, -1] - y_pre * RefSpectral_pick_adj[i, -1]
    
    
  }
  
  
  RefSpectral_pick = RefSpectral_pick_adj
}





###################################################################################################









###########



for(i in 1:length(files)){
  
  MS_img = rast(file.path(MS_image_ReadinPath, files[i]))
  MS_DN <- as.data.frame(values(MS_img))
  
  
  print(paste0("match ", i, "th: ",  MS_time[i], " with ", RefSpectral_pick$STS_time[i]))
  
  start.time <- Sys.time()
  for(j in 1:length(band_name)){
    #print(j)
    
    RefSpectral_pick_g_row = RefSpectral_pick %>% 
      filter(STS_time == RefSpectral_pick$STS_time[i])
    
    if(nrow(RefSpectral_pick_g_row) != 1 ){
      warning("KC brain error")
      RefSpectral_pick_g_row = RefSpectral_pick_g_row[1,]
    } 
    
    if(band4_MLR == TRUE){
      wv = as.numeric(gsub("STS_X", "", names(RefSpectral_pick_g_row)[2:1025]))
      RefSpectral_pick_g_row_new = RefSpectral_pick_g_row
      for(q in 1:length(wv)){
        wv_pick = which(abs(wv - wv[q]) < 15)
        RefSpectral_pick_g_row_new[, 2+q-1] = rowMeans(RefSpectral_pick_g_row[, c(2+wv_pick-1)])
      }
      RefSpectral_pick_g_row = RefSpectral_pick_g_row_new
    }
    
    
    RefSpectral_pick_g_row = RefSpectral_pick_g_row %>% slice(rep(1:n(), each = nrow(MS_DN)))
    
    
    new_data = as.data.frame(cbind(DN_imager = MS_DN[, j], RefSpectral_pick_g_row[,-1]))
    new_data$DN_imager = as.numeric(new_data$DN_imager)
    
    
    for(w in 1:length(spec_name)){
      new_data[, paste0(spec_name[w], "_div")] = new_data$DN_imager / new_data[, spec_name[w]]
    }
    #new_data = new_data[is.finite(rowSums(new_data)), ]
    
    this_model = get(paste0("model_", "Band", j))
    output = predict(this_model, newdata = new_data)
    
    r_add <- rast(nrows=216, ncols=409)
    values(r_add) <- output
    
    r_name = paste0("r", j)
    assign(r_name, r_add)
  }
  
  r_all = c(r1, r2, r3, r4, r5, r6, r7, r8, r9, r10,
            r11, r12, r13, r14, r15, r16, r17, r18, r19, r20, 
            r21, r22, r23, r24, r25)
  writeRaster(r_all, file.path(WritePath, files[i]), overwrite=TRUE)
  
  #print(paste0("Finished using ", round(Sys.time() - start.time), "s"))
}















