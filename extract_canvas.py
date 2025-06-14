import requests
import pandas as pd
import time

# Canvas API details (replace with your actual values or use environment variables)
CANVAS_BASE_URL = 'https://yourinstitution.instructure.com/api/v1'
CANVAS_API_TOKEN = 'your_canvas_api_token'
HEADERS = {'Authorization': f'Bearer {CANVAS_API_TOKEN}'}

# Helper function to paginate through Canvas API responses
def get_all_pages(url, params=None):
    results = []
    while url:
        resp = requests.get(url, headers=HEADERS, params=params)
        resp.raise_for_status()
        data = resp.json()
        if isinstance(data, dict):
            data = [data]
        results.extend(data)
        # Pagination
        if 'next' in resp.links:
            url = resp.links['next']['url']
            params = None  # Only needed for first request
        else:
            url = None
        time.sleep(0.2)  # Be nice to the API
    return results

if __name__ == "__main__":
    # Users
    users = get_all_pages(f"{CANVAS_BASE_URL}/accounts/1/users", params={'per_page': 100})
    pd.DataFrame(users).to_csv("mock_data/canvas_users.csv", index=False)
    print("Extracted Canvas users.")

    # Courses
    courses = get_all_pages(f"{CANVAS_BASE_URL}/accounts/1/courses", params={'per_page': 100})
    pd.DataFrame(courses).to_csv("mock_data/canvas_courses.csv", index=False)
    print("Extracted Canvas courses.")

    # Enrollments (for each course)
    all_enrollments = []
    for course in courses:
        course_id = course['id']
        enrollments = get_all_pages(f"{CANVAS_BASE_URL}/courses/{course_id}/enrollments", params={'per_page': 100})
        for enr in enrollments:
            enr['course_id'] = course_id
        all_enrollments.extend(enrollments)
    pd.DataFrame(all_enrollments).to_csv("mock_data/canvas_enrollments.csv", index=False)
    print("Extracted Canvas enrollments.")

    # Assignments (for each course)
    all_assignments = []
    for course in courses:
        course_id = course['id']
        assignments = get_all_pages(f"{CANVAS_BASE_URL}/courses/{course_id}/assignments", params={'per_page': 100})
        for a in assignments:
            a['course_id'] = course_id
        all_assignments.extend(assignments)
    pd.DataFrame(all_assignments).to_csv("mock_data/canvas_assignments.csv", index=False)
    print("Extracted Canvas assignments.")

    # Submissions (for each assignment)
    all_submissions = []
    for assignment in all_assignments:
        course_id = assignment['course_id']
        assignment_id = assignment['id']
        submissions = get_all_pages(f"{CANVAS_BASE_URL}/courses/{course_id}/assignments/{assignment_id}/submissions", params={'per_page': 100})
        for s in submissions:
            s['course_id'] = course_id
            s['assignment_id'] = assignment_id
        all_submissions.extend(submissions)
    pd.DataFrame(all_submissions).to_csv("mock_data/canvas_submissions.csv", index=False)
    print("Extracted Canvas submissions.") 