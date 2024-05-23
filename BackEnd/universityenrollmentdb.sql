-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: May 23, 2024 at 08:48 AM
-- Server version: 10.4.28-MariaDB
-- PHP Version: 8.2.4

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `universityenrollmentdb`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `DropCourse` (IN `student_id` INT, IN `course_id` INT)   BEGIN
    DELETE FROM Enrollments
    WHERE student_id = student_id AND course_id = course_id;
    
    -- Update the enrollment count in the Courses table
    UPDATE Courses
    SET enrollment_count = enrollment_count - 1
    WHERE course_id = course_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `EnrollStudent` (IN `student_id` INT, IN `course_id` INT)   BEGIN
    DECLARE seats_left INT DEFAULT 0;
    DECLARE unmet_prerequisites INT DEFAULT 0;
    DECLARE total_prerequisites INT DEFAULT 0;

    -- Check available seats
    SELECT (c.capacity - c.enrollment_count) INTO seats_left
    FROM Courses c
    WHERE c.course_id = course_id;

    -- Check the total number of prerequisites for the course
    SELECT COUNT(*) INTO total_prerequisites
    FROM Prerequisites p
    WHERE p.course_id = course_id;

    -- Check if the student has completed the prerequisites
    SELECT COUNT(*) INTO unmet_prerequisites
    FROM Prerequisites p
    WHERE p.course_id = course_id
    AND p.prerequisite_id NOT IN (
        SELECT e.course_id
        FROM Enrollments e
        WHERE e.student_id = student_id
    );

    -- Ensure there are seats left and prerequisites are met
    IF seats_left > 0 AND unmet_prerequisites = 0 THEN
        INSERT INTO Enrollments (student_id, course_id, enrollment_date)
        VALUES (student_id, course_id, NOW());

        -- Update the enrollment count in the Courses table
        UPDATE Courses
        SET enrollment_count = enrollment_count + 1
        WHERE course_id = course_id;
    ELSE
        -- Error handling if seats are not available or prerequisites are not met
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cannot enroll: either no seats available or prerequisites not met';
    END IF;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `courses`
--

CREATE TABLE `courses` (
  `course_id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `description` text DEFAULT NULL,
  `capacity` int(11) NOT NULL,
  `enrollment_count` int(11) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `courses`
--

INSERT INTO `courses` (`course_id`, `name`, `description`, `capacity`, `enrollment_count`) VALUES
(1, 'Introduction to Computer Science', 'Basic concepts in computer science', 30, 10),
(2, 'Data Structures', 'In-depth study of data structures', 25, 7),
(3, 'Databases', 'Fundamentals of database systems', 20, 9),
(5, 'software', 'software3rd', 21, 8),
(6, 'simulation', 'simulation 3rd', 25, 7);

-- --------------------------------------------------------

--
-- Table structure for table `enrollments`
--

CREATE TABLE `enrollments` (
  `enrollment_id` int(11) NOT NULL,
  `student_id` int(11) NOT NULL,
  `course_id` int(11) NOT NULL,
  `enrollment_date` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Triggers `enrollments`
--
DELIMITER $$
CREATE TRIGGER `CheckPrerequisites` BEFORE INSERT ON `enrollments` FOR EACH ROW BEGIN
    DECLARE prerequisite_met BOOLEAN;
    
    -- Check prerequisites
    SELECT COUNT(*) INTO prerequisite_met
    FROM Prerequisites
    WHERE course_id = NEW.course_id
    AND prerequisite_id NOT IN (
        SELECT course_id FROM Enrollments WHERE student_id = NEW.student_id
    );
    
    IF prerequisite_met > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Prerequisite not met for the course';
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `UpdateEnrollmentCount` AFTER INSERT ON `enrollments` FOR EACH ROW BEGIN
    UPDATE Courses
    SET enrollment_count = enrollment_count + 1
    WHERE course_id = NEW.course_id;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `prerequisites`
--

CREATE TABLE `prerequisites` (
  `course_id` int(11) NOT NULL,
  `prerequisite_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `prerequisites`
--

INSERT INTO `prerequisites` (`course_id`, `prerequisite_id`) VALUES
(2, 1),
(5, 3);

-- --------------------------------------------------------

--
-- Table structure for table `students`
--

CREATE TABLE `students` (
  `student_id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `date_of_birth` date DEFAULT NULL,
  `registration_date` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `students`
--

INSERT INTO `students` (`student_id`, `name`, `email`, `date_of_birth`, `registration_date`) VALUES
(1, 'Alice Johnson', 'alice@example.com', '2000-05-10', '2024-05-22 18:41:27'),
(2, 'Bob Smith', 'bob@example.com', '1999-07-22', '2024-05-22 18:41:27');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `courses`
--
ALTER TABLE `courses`
  ADD PRIMARY KEY (`course_id`);

--
-- Indexes for table `enrollments`
--
ALTER TABLE `enrollments`
  ADD PRIMARY KEY (`enrollment_id`),
  ADD UNIQUE KEY `student_id` (`student_id`,`course_id`),
  ADD KEY `course_id` (`course_id`);

--
-- Indexes for table `prerequisites`
--
ALTER TABLE `prerequisites`
  ADD PRIMARY KEY (`course_id`,`prerequisite_id`),
  ADD KEY `prerequisite_id` (`prerequisite_id`);

--
-- Indexes for table `students`
--
ALTER TABLE `students`
  ADD PRIMARY KEY (`student_id`),
  ADD UNIQUE KEY `email` (`email`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `courses`
--
ALTER TABLE `courses`
  MODIFY `course_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `enrollments`
--
ALTER TABLE `enrollments`
  MODIFY `enrollment_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `students`
--
ALTER TABLE `students`
  MODIFY `student_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `enrollments`
--
ALTER TABLE `enrollments`
  ADD CONSTRAINT `enrollments_ibfk_1` FOREIGN KEY (`student_id`) REFERENCES `students` (`student_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `enrollments_ibfk_2` FOREIGN KEY (`course_id`) REFERENCES `courses` (`course_id`) ON DELETE CASCADE;

--
-- Constraints for table `prerequisites`
--
ALTER TABLE `prerequisites`
  ADD CONSTRAINT `prerequisites_ibfk_1` FOREIGN KEY (`course_id`) REFERENCES `courses` (`course_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `prerequisites_ibfk_2` FOREIGN KEY (`prerequisite_id`) REFERENCES `courses` (`course_id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
