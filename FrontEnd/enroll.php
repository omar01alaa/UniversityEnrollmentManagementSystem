<?php
require 'config.php';

$student_id = $_POST['student_id'];
$course_id = $_POST['course_id'];

$response = [];

try {
    if ($stmt = $conn->prepare("CALL EnrollStudent(?, ?)")) {
        $stmt->bind_param('ii', $student_id, $course_id);

        if ($stmt->execute()) {
            $response = ['success' => true, 'message' => 'Successfully enrolled in course.'];
        } else {
            // Capture the error message from the MySQL procedure
            $error = $stmt->error;
            $response = ['success' => false, 'message' => 'Enrollment failed: ' . $error];
        }

        $stmt->close();
    } else {
        $response = ['success' => false, 'message' => 'Failed to prepare statement.'];
    }
} catch (mysqli_sql_exception $e) {
    // Handle the exception and return the error message
    $response = ['success' => false, 'message' => 'Enrollment failed: ' . $e->getMessage()];
}

$conn->close();

echo json_encode($response);
?>
