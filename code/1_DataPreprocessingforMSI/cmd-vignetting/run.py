import sys
import matlab.engine
import os
os.chdir(os.path.dirname(os.path.abspath(__file__)))

inputfile_path = sys.argv[1]    # 读入待渐晕较正的文件夹路径
outputfile_path = sys.argv[2]   # 读入校正后的文件输出路径
eng = matlab.engine.start_matlab()  # 启动matlab
eng.Vignetting_correction(
    inputfile_path, outputfile_path, nargout=0)   # 调用matlab脚本执行程序
