# frozen_string_literal: true

class LinebotsController < ApplicationController
  # LINE APIを返すときはつける必要がある
  protect_from_forgery :except => [:create]
  before_action :validate_signature, only: [:create]

  def create
    client.parse_events_from(body).each do |event|
      client.reply_message(event['replyToken'], message(event))
    end
    head :ok
  end

  private

  def body
    @body ||= request.body.read
  end

  def client
    @client ||= Line::Bot::Client.new do |config|
      config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
      config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
    end
  end

  def validate_signature
    signature = request.env['HTTP_X_LINE_SIGNATURE']
    head :bad_request unless client.validate_signature(body, signature)
  end

  def events
    @events ||= client.parse_events_from(body)
  end

  def message(event)
    # ここに書いていく
    if event.message['text'].include?("ハロー")
      response = "こんにちは！！"
    end

    case event
    when Line::Bot::Event::Postback
      LineBot::PostbackEvent.send(event['postback']['data'])
    when Line::Bot::Event::Message
      if event['message']['text'] =~ /カテゴリ/
        LineBot::Messages::LargeCategoriesMessage.new.send

      elsif event['message']['text'] =~ /おみくじ/
        {
          type: 'text',
          text: '今日の運勢は' + ['大吉', '中吉', '小吉', '凶'].sample + 'です'
        }

      elsif event['message']['text'] =~ /FlexMessage/
        LineBot::Messages::SampleMessage.new.send

      elsif event['message']['text'] =~ /じゃんけん/
        LineBot::Messages::JankenMessage.new.send

      else
        {
          type: 'text',
          text: event['message']['text']
        }
        nil
      end
    end

    # case event
    # when Line::Bot::Event::Message
    #   {
    #     type: 'text',
    #     text: event['message']['text']
    #   }
    # end
  end
end
