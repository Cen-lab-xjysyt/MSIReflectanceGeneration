library(corrplot)
library(dplyr)
library(tidyr)
library(ggplot2)
library(stringr)


# read-in path example
Spec_ReadinPath = "Z:/Cen_Lab/Projects/Drone_radiometric_correction/耐寒性实验/0129/STS"

############ begin
files = list.files(path = file.path(Spec_ReadinPath), pattern = ".txt")
files

# change path accordingly
dark = read.csv(file.path("Z:/Cen_Lab/Projects/Drone_radiometric_correction/upload/data", "spectrometer_darkcurrent.csv"))

wavelength_pick = c("632","641","649","657","666", "675","679",
                    "693", "718", "732","745","758","771","784",
                    "796", "808","827","838","849","859","869",
                    "872")
band_name = c("Band4","Band5","Band6","Band7","Band8","Band9",
              "Band10", "Band11", "Band12", "Band13", "Band14",
              "Band15", "Band16", "Band17", "Band18",
              "Band19", "Band20", "Band21", "Band22", "Band23", 
              "Band24", "Band25")

summary = as.data.frame(matrix(nrow = 0, ncol = 23))
summary_all = as.data.frame(matrix(nrow = 0, ncol = 1025))
for(i in 1:length(files)){  
  
  this_file_path = file.path(Spec_ReadinPath, files[i])
  
  # read single file
  dt = read.table(this_file_path, skip = 17, stringsAsFactors = F)
  dt = dt[-nrow(dt), ]
  dt = dt[-nrow(dt), ]
  if(nrow(dt) != 1024) stop("KC says check check pls")
  names(dt) = c("wavelength", "ref_DN")
  dt$ref_DN = as.numeric(dt$ref_DN)
  
  # check if overexposure
  if(any(sum(dt$ref_DN == "16383"))) warning("deal with overexposure problem")
  
  # dark current correction
  dt$ref_DN = dt$ref_DN - dark$dark_current
  
  # exposure time normalization
  exp_time_vector = readLines(this_file_path, n = 9)[9]
  exp_time_vector = str_split(exp_time_vector, " ")[[1]]
  if(exp_time_vector[3] != "(S07841)") stop("KC says check check pls")
  exp_time = as.numeric(exp_time_vector[2])/1000
  dt$ref_DN = dt$ref_DN / exp_time * 100  # 100ms was used in model build
  
  # add time stamp
  mod_time_vector = readLines(this_file_path, n = 3)[3]
  mod_time_vector = str_split(mod_time_vector, " ")[[1]]
  if(mod_time_vector[1] != "数据:") stop("KC says check check pls")
  time = mod_time_vector[5]
  
  # write csv for all bands
  tt = dt
  tt$wavelength = as.numeric(tt$wavelength)
  summary_all[nrow(summary_all)+1, ] = c(time, tt$ref_DN)
  
  # pick bands closest to MSI bands
  keep_row = c()
  for(j in 1:length(wavelength_pick)){
    diff = abs(as.numeric(dt$wavelength) - as.numeric(wavelength_pick)[j])
    index = which(diff == min(diff))
    keep_row = c(keep_row , index)
  }
  dt = dt[keep_row, ]
  rownames(dt) = wavelength_pick
  dt$ref_DN = as.numeric(dt$ref_DN)
  
  # write csv for selected bands
  summary[nrow(summary)+1, ] = c(time, dt$ref_DN)
  
  if(i %% 100 == 0) print(paste(i/length(files) * 100, "% done"))
}


names(summary) = c("time", band_name)
summary$time = format(as.POSIXct(summary$time, format = "%H:%M:%S"), format = "%H:%M:%S")
dim(summary)

summary_all_bands = tt$wavelength
names(summary_all) = c("time", summary_all_bands)
summary_all$time = format(as.POSIXct(summary_all$time, format = "%H:%M:%S"), format = "%H:%M:%S")
dim(summary_all)


write.csv(summary, file.path(Spec_ReadinPath, "RefSpectral.csv"), row.names = FALSE)
write.csv(summary_all, file.path(Spec_ReadinPath, "RefSpectral_all.csv"), row.names = FALSE)


