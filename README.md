# 💼 Job Portal Web App

A modern job portal platform built with **Ruby on Rails**, where job seekers can browse, search, and apply to jobs, and employers can post job opportunities. The platform includes user authentication, role-based access (job seeker vs. employer), and application tracking.

## 🚀 Features

- 👥 User Authentication (Devise)
- 🎭 Role-Based Access: Job Seeker & Employer
- 📝 Post, Update, and Delete Jobs (Employers)
- 🔍 Browse & Apply for Jobs (Job Seekers)
- 📄 Cover Letter Submission
- 📊 Resume-to-Job Description Matching with Score
- 🧮 Applicant Match Score Visible to Recruiters
- ✉️ Recruiters Can Contact Job Seekers via Email
- 🛡️ Secure, Clean UI using Bootstrap 5
- 📂 Organized MVC structure

---

## 🛠️ Tech Stack

- **Backend:** Ruby on Rails
- **Frontend:** HTML, ERB, Bootstrap 5
- **Authentication:** Devise
- **Database:** SQLite3 (development) / PostgreSQL (production-ready)
- **Icons:** Bootstrap Icons

---

✅ **Completed Tasks**

## 🔧  1. Project Setup
- Initialized a new Ruby on Rails application.
- Installed and configured Devise for user authentication.
- Set up application routes using RESTful conventions.

## 👩‍💼  2. User Roles and Authentication
- Integrated customized `devise_for :users` in `routes.rb`.
- Created different roles such as Job Seeker.
- Restricted access to application creation only for authenticated job seekers.

## 💼 3. Job Listings
- Generated `Job` model with fields like `title`, `description`, `company_name`, `location`, `employment_type`, `salary`.
- Implemented full CRUD functionality for jobs (index, show, new, edit, create, update, destroy).
- Displayed job listings dynamically on the homepage using `@recent_jobs`.

## 📄  4. Applications
- Generated `Application` model with `cover_letter`, and associations to `Job` and `User`.
- Created `ApplicationsController` with `new` and `create` actions.
- Enforced authentication and authorization (`before_action :authenticate_user!`, only job seekers).
- Built application form view.

## 🌐  5. Frontend & Views
- Designed the homepage
  - A call-to-action banner.
  - A dynamic section for recent job opportunities.
  - Conditional logic for "Sign Up" (if user not signed in).
- Implemented responsive Bootstrap UI for cards, buttons, and layout.
- Built clean and modern interface using Bootstrap 5.

## 🧠  6. Controller Logic
- Used `@job.applications.build` and `@application.user = current_user` in the `create` action.
- Handled success/failure flows with `redirect_to` and `render :new`.

## 🛠️  7. Routing
- Defined nested routes for applications under jobs.
- Set root route to `home#index`.
- Added a basic health check route `get "up"`.

## 🧮  8. Resume Matching & Recruiter Tools
- ✅ Implemented resume-to-job description match functionality using keyword similarity.
- ✅ Displayed **match score** to recruiters for each applicant.
- ✅ Recruiters can **add, update, and delete** job posts.
- ✅ Recruiters can **contact job seekers via email** directly from the dashboard.

---

## 🔧 Setup Instructions

### 🚀 Getting Started

Follow the steps below to set up the project locally:

### 1. Clone the Repository

```bash
git clone https://github.com/Maheenrz/job-portal.git
cd job-portal



### 2. Install Dependencies

```bash
bundle install
```

### 3. Setup the Database

```bash
rails db:create db:migrate db:seed
```

### 4. Run the Server

```bash
rails server
```

Then open your browser and visit:

```
http://localhost:3000
```
![signup](https://github.com/user-attachments/assets/0bbe3605-cb92-42a3-aae2-6835f7c4c4c7)
![welcomepage](https://github.com/user-attachments/assets/4d628650-3a8d-4d35-9ab4-936d505acc79)
![profileupdate](https://github.com/user-attachments/assets/8438a39b-eabb-4366-858a-a9cc63286ca5)
![jobpost_form](https://github.com/user-attachments/assets/11dd48c7-f690-4a92-b653-f78f38ccd8c5)
![job_post](https://github.com/user-attachments/assets/0c62b001-be9e-4cd9-9b9f-fc8be7fabeb3)
![jobListing](https://github.com/user-attachments/assets/e4bfc5c8-1550-4533-a602-2d74176bd776)
![resume_upload](https://github.com/user-attachments/assets/c5b54f08-dc7b-4685-b3dc-d6370ed463c8)
![resume-analyze](https://github.com/user-attachments/assets/06f99ef3-529c-47e7-a553-750acb873a38)
![applicant_jobtoresumematch](https://github.com/user-attachments/assets/7a313fa7-37ec-48f0-978f-335a0171f379)
