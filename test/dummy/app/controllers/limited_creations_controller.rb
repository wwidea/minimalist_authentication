# frozen_string_literal: true

class LimitedCreationsController < ApplicationController
  skip_before_action :authorization_required

  self.cache_store = ActiveSupport::Cache::MemoryStore.new

  limit_creations

  def create
    head :ok
  end
end
