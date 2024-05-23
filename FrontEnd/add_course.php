<?php
require 'config.php';

$course_name = $_POST['course_name'];
$description = $_POST['description'];
$capacity = $_POST['capacity'];

$response = [];

if ($stmt = $conn->prepare('INSERT INTO Courses (name, description, capacity) VALUES (?, ?, ?)')) {
    $stmt->bind_param('ssi', $course_name, $description, $capacity);

    if ($stmt->execute()) {
        $response = ['success' => true, 'message' => 'Course added successfully.'];
    } else {
        $response = ['success' => false, 'message' => $stmt->error];
    }

    $stmt->close();
} else {
    $response = ['success' => false, 'message' => 'Failed to prepare statement.'];
}

$conn->close();

echo json_encode($response);
?>
