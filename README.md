# 💼 Job Portal Web App

A modern job portal platform built with **Ruby on Rails**, where job seekers can browse, search, and apply to jobs, and employers can post job opportunities. The platform includes user authentication, role-based access (job seeker vs. employer), and application tracking.



## 🚀 Features

- 👥 User Authentication (Devise)
- 🎭 Role-Based Access: Job Seeker & Employer
- 📝 Post and Manage Jobs (Employers)
- 🔍 Browse & Apply for Jobs (Job Seekers)
- 📄 Cover Letter Submission
- 🛡️ Secure, Clean Design using Bootstrap 5
- 📂 Organized MVC structure


## 🛠️ Tech Stack

- **Backend:** Ruby on Rails
- **Frontend:** HTML, ERB, Bootstrap 5
- **Authentication:** Devise
- **Database:** SQLite3 (development) / PostgreSQL (production-ready)
- **Icons:** Bootstrap Icons

---

✅ **Completed Tasks**
🔧 ## 1. Project Setup
Initialized a new Ruby on Rails application.

Installed and configured Devise for user authentication.

Set up application routes using RESTful conventions.

👩‍💼 ## 2. User Roles and Authentication
Integrated devise_for :users in routes.rb.

Created different roles such as Job Seeker (via current_user.job_seeker? logic).

Restricted access to application creation only for authenticated job seekers.

💼 ## 3. Job Listings
Generated Job model with fields like title, description, company_name, location, employment_type, salary.

Implemented full CRUD functionality for jobs (index, show, new, edit, create, update, destroy).

Nested routes: jobs/:job_id/applications/new for job applications.

Displayed job listings dynamically on the homepage using @recent_jobs.

📄 ## 4. Applications
Generated Application model with cover_letter, and associations to Job and User.

Created ApplicationsController with new and create actions.

Enforced authentication and authorization (before_action :authenticate_user!, only_job_seekers!).

Built application form view.

🌐 ## 5. Frontend & Views
Designed the homepage in home/index.html.erb with:

A call-to-action banner.

A dynamic section for recent job opportunities.

Conditional logic for "Join Now" (if user not signed in).

Jobs View in show.html.erb and index.html.erb . 

Implemented responsive Bootstrap UI for cards, buttons, and layout.

🧠 ## 6. Controller Logic
Used @job.applications.build and @application.user = current_user in the create action.

Handled success/failure flows with redirect_to and render :new.

Used helper methods like number_to_currency, user_signed_in?, current_user.

🛠️ ## 7. Routing
Defined nested routes for applications under jobs.

Set root route to home#index.

Added a basic health check route get "up".


## 🔧 Setup Instructions

Great start! Here's a **corrected and cleaner version** of that installation section for your `README.md` — properly formatted and consistent in markdown syntax:

---

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

