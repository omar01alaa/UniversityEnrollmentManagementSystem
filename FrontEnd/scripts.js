document.addEventListener('DOMContentLoaded', () => {
    const enrollForm = document.getElementById('enrollForm');
    const addCourseForm = document.getElementById('addCourseForm');
    const messageDiv = document.getElementById('message');

    if (enrollForm) {
        enrollForm.addEventListener('submit', async (event) => {
            event.preventDefault();
            const formData = new FormData(enrollForm);
            const response = await fetch('enroll.php', {
                method: 'POST',
                body: formData
            });
            const result = await response.json();
            messageDiv.textContent = result.message;
            messageDiv.style.color = result.success ? 'green' : 'red';
        });
    }

    if (addCourseForm) {
        addCourseForm.addEventListener('submit', async (event) => {
            event.preventDefault();
            const formData = new FormData(addCourseForm);
            const response = await fetch('add_course.php', {
                method: 'POST',
                body: formData
            });
            const result = await response.json();
            messageDiv.textContent = result.message;
            messageDiv.style.color = result.success ? 'green' : 'red';
        });
    }
});
