
// Ví dụ sử dụng trong StatefulWidget
class ExampleUsage extends StatefulWidget {
  @override
  State<ExampleUsage> createState() => _ExampleUsageState();
}

class _ExampleUsageState extends State<ExampleUsage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Examples'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () {
                NotificationService.showSuccess(
                  context,
                  title: 'Thành công!',
                  message: 'Dữ liệu đã được lưu thành công',
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('Show Success'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                NotificationService.showError(
                  context,
                  title: 'Lỗi!',
                  message: 'Không thể kết nối đến server',
                  onTap: () {
                    print('Error notification tapped');
                  },
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Show Error'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                NotificationService.showWarning(
                  context,
                  title: 'Cảnh báo!',
                  message: 'Dung lượng lưu trữ sắp hết',
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text('Show Warning'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                NotificationService.showInfo(
                  context,
                  title: 'Thông tin',
                  message: 'Phiên bản mới đã có sẵn',
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: const Text('Show Info'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                NotificationService.showCustom(
                  context,
                  title: 'Thông báo tùy chỉnh',
                  message: 'Đây là thông báo với màu tùy chỉnh',
                  backgroundColor: Colors.purple,
                  textColor: Colors.white,
                  customIcon: const Icon(Icons.star, color: Colors.yellow),
                  position: NotificationPosition.center,
                  duration: const Duration(seconds: 5),
                  showProgressBar: true,
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
              child: const Text('Show Custom'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                // Hiển thị nhiều thông báo liên tiếp
                NotificationService.showInfo(
                  context,
                  title: 'Thông báo 1',
                  message: 'Đây là thông báo đầu tiên',
                );
                
                Future.delayed(const Duration(milliseconds: 500), () {
                  NotificationService.showSuccess(
                    context,
                    title: 'Thông báo 2',
                    message: 'Đây là thông báo thứ hai',
                  );
                });
              },
              child: const Text('Show Multiple'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                NotificationOverlay.clear();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
              child: const Text('Clear All'),
            ),
          ],
        ),
      ),
    );
  }
}