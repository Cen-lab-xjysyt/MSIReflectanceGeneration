import os                 ##############  ！！！！！！！！！！！！每次运行前需要修改107行和126行内容
import cv2
import pytesseract
from openpyxl import Workbook
import numpy as np
import re
import pandas as pd

def preprocess_image(image, save_path=None):
    # 放大图像
    scale_percent = 500  # 放大百分比
    width = int(image.shape[1] * scale_percent / 100)
    height = int(image.shape[0] * scale_percent / 100)
    dim = (width, height)
    image = cv2.resize(image, dim, interpolation=cv2.INTER_LINEAR)

    # 转换为灰度图像
    gray_image = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)

    # 应用高斯模糊
    # blurred_image = cv2.GaussianBlur(gray_image, (3, 3), 0)

    # 二值化
    _, binary_image = cv2.threshold(gray_image, 0, 255, cv2.THRESH_BINARY + cv2.THRESH_OTSU)

    # # 定义腐蚀和膨胀的内核
    # erosion_kernel = np.ones((3, 3), np.uint8)  # 根据需要调整内核大小
    # dilation_kernel = np.ones((3, 3), np.uint8)  # 根据需要调整内核大小
    #
    # # 腐蚀操作
    # eroded = cv2.erode(binary_image, erosion_kernel, iterations=1)
    #
    # # 膨胀操作
    # dilated = cv2.dilate(eroded, dilation_kernel, iterations=1)
    #
    # binary_image = dilated

    # 或者尝试自适应阈值
    # binary_image = cv2.adaptiveThreshold(blurred_image, 255, cv2.ADAPTIVE_THRESH_GAUSSIAN_C, cv2.THRESH_BINARY, 11, 2)

    # 保存预处理后的图像，以便进行检查
    if save_path:
        cv2.imwrite(save_path, binary_image)
    return binary_image


def extract_numbers(image, roi, save_preprocess_path=None):
    x, y, w, h = roi
    cropped_image = image[y:y+h, x:x+w]
    preprocessed_image = preprocess_image(cropped_image)  # 确保你有这个预处理函数

    # 配置 pytesseract 以仅识别数字
    custom_config = r'--oem 3 --psm 6 outputbase digits'
    text = pytesseract.image_to_string(preprocessed_image, config=custom_config)

    # 保存预处理后的图像
    if save_preprocess_path:
        cv2.imwrite(save_preprocess_path, preprocessed_image)

    # 仅包含数字的正则表达式模式
    pattern = re.compile(r'\d+')

    # 使用正则表达式搜索文本中的数字
    matches = pattern.findall(text.strip())

    # 检查是否有匹配的数字
    if matches:
        # 返回第一个匹配的数字
        return matches[0]
    else:
        # 如果没有匹配的数字，返回0
        return "0"

def correct_sequence(numbers, filenames):
    """
    校正数字序列，确保递增，并且考虑到可能存在连续两个相同的数字。
    同时校正对应的文件名字。
    :param numbers: 原始识别到的数字列表。
    :param filenames: 原始识别到的文件名列表。
    :return: 校正后的数字列表和文件名列表。
    """
    if not numbers:
        return [], []

    corrected_numbers = [numbers[0]]
    corrected_filenames = [filenames[0]]
    for idx, num in enumerate(numbers[1:], start=1):
        # 如果数字和前一个相同，或者正好比前一个数字大1，则接受这个数字
        if num == corrected_numbers[-1] or num == corrected_numbers[-1] + 1:
            corrected_numbers.append(num)
            corrected_filenames.append(filenames[idx])

        # 如果数字小于前一个数字，则可能是误识别，用前一个数字代替，并且跳过这个文件名
        if num < corrected_numbers[-1]:
            if num % 2 == 0:
                corrected_numbers.append(corrected_numbers[-1] + 1)
                corrected_filenames.append(filenames[idx])

        # 如果数字比前一个数字大1以上，则可能是误识别，用前一个数字+1代替，并且跳过这个文件名
        elif num > corrected_numbers[-1] + 1:
            corrected_numbers.append(corrected_numbers[-1] + 1)
            corrected_filenames.append(filenames[idx])  # 使用前一个正确的文件名


    # 填充可能缺失的数字
    final_numbers = []
    final_filenames = []
    for i in range(3, corrected_numbers[-1] + 1):
        if i in corrected_numbers:
            index = corrected_numbers.index(i)
            final_numbers.append(i)
            final_filenames.append(corrected_filenames[index])
        else:
            # 若缺失，用前一个数字填充，并且从file_names中取得对应的文件名
            final_numbers.append(final_numbers[-1])
            next_filename = file_names.get(final_numbers[-1] + 1)
            final_filenames.append(next_filename)

    return final_numbers, final_filenames


def main():
    input_folder = 'E:\Desktop\output_frames\架次2\part4'  # 包含图片的文件夹
    output_file = 'E:\Desktop\output_frames\output-part4.xlsx'  # 输出Excel文件的名称
    output_file2 = 'E:\Desktop\output_frames\output2-part4.xlsx'  # 输出Excel文件的名称

    # 设置ROI坐标和大小
    roi1 = (782, 503, 40, 15)  # (x, y, w, h)

    wb = Workbook()
    ws = wb.active

    extracted_numbers = []
    file_names = {}  # 用于存储每个数字和其对应的最早文件名
    image_files_for_correction = []

    # 文件重命名
    # 遍历文件夹中的所有文件
    for filename in os.listdir(input_folder):
        if filename.endswith('.png') and filename.startswith('keyframe_'):
            # 提取文件名中的数字部分
            parts = filename.split('_')
            if len(parts) == 3:
                number = parts[1]
                # 如果数字长度为3位，则进行填充
                if len(number) == 3:
                    new_number = number.zfill(4)  # 填充为4位数
                    new_filename = f"keyframe_{new_number}_{parts[2]}"

                    # 重命名文件
                    old_file_path = os.path.join(input_folder, filename)
                    new_file_path = os.path.join(input_folder, new_filename)
                    os.rename(old_file_path, new_file_path)

                    print(f"Renamed: {filename} -> {new_filename}")

    print("Renaming completed.")

    for idx, image_file in enumerate(sorted(os.listdir(input_folder)), start=1):
        image_path = os.path.join(input_folder, image_file)
        image = cv2.imread(image_path)

        if image is None:
            print(f"Error: Unable to read image {image_file}")
            continue

        text1 = extract_numbers(image, roi1)
        print(f"Image {idx}: text1 = {text1}")

        # 尝试将提取的文本转换为整数
        try:
            number = int(text1)
            extracted_numbers.append(number)
            image_files_for_correction.append(image_file)
            if number not in file_names or file_names[number] > image_file:  # 存储数字对应的最早文件名
                file_names[number] = image_file
        except ValueError:
            print(f"Warning: Unable to convert extracted text to number for image {image_file}")

    # 校正序列及其对应的图片名字
    corrected_numbers, corrected_filenames = correct_sequence(extracted_numbers, image_files_for_correction)

    # 将校正后的数字和文件名写入工作表
    for number, filename in zip(corrected_numbers, corrected_filenames):
        ws.append([number, filename])

    wb.save(output_file)
    print(f"Data saved to {output_file}")

    # 获取文件夹中所有文件的文件名
    file_names = [f for f in os.listdir(input_folder) if os.path.isfile(os.path.join(input_folder, f))]

    # 将文件名存储到DataFrame中
    df = pd.DataFrame(file_names, columns=["File Names"])

    # 将DataFrame保存为Excel文件
    df.to_excel(output_file2, index=False)

    print(f"File names have been saved to {output_file2}.")


if __name__ == '__main__':
    pytesseract.pytesseract.tesseract_cmd = r'C:\Program Files\Tesseract-OCR\tesseract.exe'  # 请根据实际安装路径进行修改
    main()