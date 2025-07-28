文件说明：
1. 代码和一些必要的文本文件信息较多，故分类较多，没有整合，需要执行的代码为python的run.py文件；
2. 测试数据在Input文件夹下的ms文件夹，包含一个.raw多光谱文件和.hdr头文件记录信息；
3. 脚本功能为解压缩ms文件夹下的.raw文件，执行完后会得到346张tif照片，并对这些图片进行渐晕较正处理，最后存储在指定的输出文件夹；

配置说明（之前安装过了就不用了）：
1. 安装64位python（我的测试版本为3.7.9）；
2. 安装matlab（我的测试版本为windows 2021a），且在extern\engines\python文件夹下执行过setup.py；

执行说明：
1. windows下，cmd界面，输入：python run.py Inputfile_Path(测试数据中Input/ms的路径) Output_Path(自定义的输出路径)；
2. 执行时间约为66s，cmd界面会实时打印出已完成的进度（约2s一次）；
