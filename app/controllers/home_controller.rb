class HomeController < ApplicationController
    def index
      @recent_jobs = Job.order(created_at: :desc).limit(6)
    end
  end