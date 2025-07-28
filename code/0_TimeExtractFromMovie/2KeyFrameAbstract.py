import cv2
import os

def save_keyframe(frame, output_folder, time_ms):
    # 将时间从毫秒转换为秒，并格式化字符串保留两位小数
    seconds = int(time_ms // 1000)
    milliseconds = int(time_ms % 1000)
    output_path = os.path.join(output_folder, f'keyframe_{seconds:03d}_{milliseconds:03d}.png')
    cv2.imwrite(output_path, frame)

def is_keyframe(prev_frame, curr_frame, roi, threshold):
    x, y, w, h = roi
    prev_roi = prev_frame[y:y+h, x:x+w]
    curr_roi = curr_frame[y:y+h, x:x+w]

    diff = cv2.absdiff(prev_roi, curr_roi)
    gray_diff = cv2.cvtColor(diff, cv2.COLOR_BGR2GRAY)
    _, thresh_img = cv2.threshold(gray_diff, 30, 255, cv2.THRESH_BINARY)
    non_zero_count = cv2.countNonZero(thresh_img)

    if non_zero_count >= threshold:
        return True
    else:
        return False

def main():
    video_file = r'Z:\Projects\Drone_radiometric_correction\阴阳图\录制视频\20240813-131116.mp4'  # 请替换为你的视频文件路径
    output_folder = r'E:\Desktop\output_frames'  # 保存关键帧的文件夹
    if not os.path.exists(output_folder):
        os.makedirs(output_folder)

    cap = cv2.VideoCapture(video_file)

    if not cap.isOpened():
        print(f"Error: Unable to open video file {video_file}")
        return

    ret, prev_frame = cap.read()
    if not ret:
        print("No frames in the video.")
        return

    # 设置感兴趣区域（ROI）的坐标和大小
    roi_x, roi_y, roi_w, roi_h = 782, 503, 40, 15
    roi = (roi_x, roi_y, roi_w, roi_h)

    # 设置检测变化的阈值
    threshold = 5

    while cap.isOpened():
        time_ms = cap.get(cv2.CAP_PROP_POS_MSEC)  # 获取当前帧的时间戳
        ret, curr_frame = cap.read()
        if not ret:
            print("No more frames.")
            break

        print(f"Processing frame at {time_ms} ms")

        if is_keyframe(prev_frame, curr_frame, roi, threshold):
            print(f"Keyframe detected at {time_ms} ms")
            save_keyframe(curr_frame, output_folder, time_ms)

        prev_frame = curr_frame

    cap.release()

if __name__ == '__main__':
    main()