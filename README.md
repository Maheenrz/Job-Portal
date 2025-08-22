# 💼 Job Portal Web App

A modern job portal platform built with **Ruby on Rails**, where job seekers can browse, search, and apply to jobs, and employers can post job opportunities. The platform includes user authentication, role-based access (job seeker vs. employer), application tracking and **smart resume to Job match Analyzer**.

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

## Applicant Features
- ✅ Can apply to multiple job postings.
- ✅ Receives a resume-to-job match score to evaluate how well they fit the job.
- ✅ Can be contacted by recruiters directly via email.

## 🧮  8. Resume Matching & Recruiter Tools
- ✅ Implemented resume-to-job description match functionality using keyword similarity.
- ✅ Displayed **match score** to recruiters for each applicant.
- ✅ Recruiters can **add, update, and delete** job posts.
- ✅ Recruiters can **contact job seekers via email** directly from the dashboard.

---

## 📸 Screenshots

| Applicant Resume Match | Job Listings | Job Post |
|-------------------------|--------------|----------|
| ![Applicant Resume Match](https://github.com/Maheenrz/Job-Portal/blob/main/public/imagesjp/applicant_jobtoresumematch.png) | ![Job Listings](https://github.com/Maheenrz/Job-Portal/blob/main/public/imagesjp/jobListing.png) | ![Job Post](https://github.com/Maheenrz/Job-Portal/blob/main/public/imagesjp/job_post.png) |

| Job Post Form | Profile Update | Resume Analyze |
|---------------|----------------|----------------|
| ![Job Post Form](https://github.com/Maheenrz/Job-Portal/blob/main/public/imagesjp/jobpost_form.png) | ![Profile Update](https://github.com/Maheenrz/Job-Portal/blob/main/public/imagesjp/profileupdate.png) | ![Resume Analyze](https://github.com/Maheenrz/Job-Portal/blob/main/public/imagesjp/resume-analyze.png) |

| Resume Upload | Signup Page | Welcome Page |
|---------------|-------------|--------------|
| ![Resume Upload](https://github.com/Maheenrz/Job-Portal/blob/main/public/imagesjp/resume_upload.png) | ![Signup Page](https://github.com/Maheenrz/Job-Portal/blob/main/public/imagesjp/signup.png) | ![Welcome Page](https://github.com/Maheenrz/Job-Portal/blob/main/public/imagesjp/welcomepage.png) |


## 🔧 Setup Instructions

### 🚀 Getting Started

Follow the steps below to set up the project locally:

### 1. Clone the Repository

```bash
git clone https://github.com/Maheenrz/job-portal.git
cd job-portal
```


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


