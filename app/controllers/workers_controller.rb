class WorkersController < ApplicationController
  before_filter :authenticate_admin!

  def index
    @workers = Worker.order('worker_type_id', 'last_seen_at DESC').all
  end

  def tr_worker
    worker = Worker.find params[:id]
    render worker
  end
end
