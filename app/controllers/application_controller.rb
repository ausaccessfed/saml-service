# frozen_string_literal: true

class ApplicationController < ActionController::Base
  Forbidden = Class.new(StandardError)
  private_constant :Forbidden
  rescue_from Forbidden, with: :forbidden

  Unauthorized = Class.new(StandardError)
  private_constant :Unauthorized
  rescue_from Unauthorized, with: :unauthorized

  protect_from_forgery with: :exception
  before_action :ensure_authenticated, except: :health
  after_action :ensure_access_checked, except: :health

  def subject
    subject = session[:subject_id] && Subject[session[:subject_id]]
    return nil unless subject.try(:functioning?)

    @subject = subject
  end

  def health
    Redis.new.ping && Sequel::Model.db.test_connection
    render body: 'ok'
  end

  protected

  def ensure_authenticated
    return force_authentication unless session[:subject_id]

    @subject = Subject[session[:subject_id]]
    raise(Unauthorized, 'Subject invalid') unless @subject
    raise(Unauthorized, 'Subject not functional') unless @subject.functioning?
  end

  def ensure_access_checked
    return if @access_checked

    method = "#{self.class.name}##{params[:action]}"
    raise("No access control performed by #{method}")
  end

  def check_access!(action)
    raise(Forbidden) unless subject.permits?(action)

    @access_checked = true
  end

  def public_action
    @access_checked = true
  end

  def unauthorized
    reset_session
    render 'errors/unauthorized', status: :unauthorized
  end

  def forbidden
    render 'errors/forbidden', status: :forbidden
  end

  def force_authentication
    session[:return_url] = request.url if request.get?
    redirect_to('/auth/login')
  end
end
