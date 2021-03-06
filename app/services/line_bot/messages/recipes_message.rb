# frozen_string_literal: true

module LineBot
  module Messages
    # 知らないイベントが発生したとき
    class RecipesMessage
      include LineBot::Messages::Concern::Carouselable

      def send(small_category_id)
        bubbles = []
        small_categories = Category.where(parent_category_id: middle_category_id)
        if small_categories.count == 1
          LineBot::Messages::UnknownMessage.new.send
        else
          small_categories.each_slice(5) do |categories|
            bubbles << bubble(categories)
          end

          carousel('レシピ検索', bubbles)
        end
      end

      def category_button(category)
        {
          "type": "box",
          "layout": "horizontal",
          "contents": [
            {
              "type": "text",
              "text": category.name,
              "gravity": "center",
              "align": "start"
            },
            {
              "type": "button",
              "action": {
                "type": "postback",
                "label": "調べる",
                "data": "type=small_search&category_id=#{category.category_id}"
              }
            }
          ]
        }
      end

      def bubble(categories)
        {
          "type": "bubble",
          "header": {
            "type": "box",
            "layout": "vertical",
            "contents": [
              {
                "type": "text",
                "text": "レシピ検索"
              }
            ]
          },
          "body": {
            "type": "box",
            "layout": "vertical",
            "contents": categories.map { |category| category_button(category) }
          }
        }
      end
    end
  end
end
