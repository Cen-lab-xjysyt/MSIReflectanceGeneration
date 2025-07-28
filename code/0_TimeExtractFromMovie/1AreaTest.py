import cv2

def draw_rectangle(frame, x, y, width, height, color, thickness):
    cv2.rectangle(frame, (x, y), (x + width, y + height), color, thickness)

def main():
    video_file = r'Z:\Projects\Drone_radiometric_correction\阴阳图\录制视频\20240813-122114.mp4'  # 请替换为你的视频文件路径
    cap = cv2.VideoCapture(video_file)

    if not cap.isOpened():
        print(f"Error: Unable to open video file {video_file}")
        return

    frame_count = 0

    while cap.isOpened():
        ret, frame = cap.read()
        if not ret:
            print("No more frames.")
            break

        frame_count += 1
        print(f"Processing frame {frame_count}")

        # 设置区域坐标和大小
        x, y, width, height = 782, 503, 40, 15
        color = (0, 255, 0)  # 绿色
        thickness = 2

        draw_rectangle(frame, x, y, width, height, color, thickness)

        cv2.imshow('Video with Rectangle', frame)

        # 按'q'键退出
        if cv2.waitKey(30) & 0xFF == ord('q'):
            break

    cap.release()
    cv2.destroyAllWindows()

if __name__ == '__main__':
    main()