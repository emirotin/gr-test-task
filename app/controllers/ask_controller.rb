# typed: true
# frozen_string_literal: true

require "#{Rails.root}/lib/ask_openai.rb"

# AskController
class AskController < ApplicationController
  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/MethodLength
  def ask
    question = params[:question]

    render nothing: true, status: :bad_request and return if question.nil? || question.empty?

    question = question.strip
    question << '?' unless question.end_with?('?')

    openai = AskOpenai.new

    db_question = Question.find_by(question:)

    if db_question
      db_question.ask_count += 1
    else
      answer, context = openai.ask(question)
      db_question = Question.create(question:, answer:, context:, ask_count: 1)
    end

    db_question.save
    render json: { question: db_question.question, answer: db_question.answer, id: db_question.id }
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/MethodLength
end
