class LinebotController < ApplicationController
    require "line/bot"  # gem "line-bot-api"
 
     # callbackアクションのCSRFトークン認証を無効
     protect_from_forgery :except => [:callback]
 
     def client
       @client ||= Line::Bot::Client.new { |config|
         config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
         config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
       }
     end
     
     def callback
       body = request.body.read
       @data = Datum.all #データベース内の全てのデータ
   
       signature = request.env["HTTP_X_LINE_SIGNATURE"]
       unless client.validate_signature(body, signature)
         error 400 do "Bad Request" end
       end
   
       events = client.parse_events_from(body)
   
       events.each { |event|
        case event
        when Line::Bot::Event::Message #ユーザーからメッセージが送られたとき
            case event.type
            when Line::Bot::Event::MessageType::Text
               str = event.message["text"]
               
                #helpを表示させる
                case str
                when "help"
                   message = [
                       {type: "text",text: "和音の名前(コードネーム)は主に五線譜の上部に記載されています。記載されている記号通りに入力してみてください(^^♪"},
                       {type: "image",originalContentUrl: "https://pbs.twimg.com/media/EDwcieAU4AMnNrR?format=jpg&name=900x900" ,previewImageUrl: "https://pbs.twimg.com/media/EDwcieAU4AMnNrR?format=jpg&name=900x900"},
                   ]
                when "和音の種類を教えて"
                    message = [
                        {type: "text",text:"[長三和音(メジャーコード)]：長音階の1度、3度、5度からなる三和音です。明るい印象を与える和音です。"},
                        {type: "text",text:"[短三和音(マイナーコード)]：短音階の1度、3度、5度からなる三和音です。長三和音の3度が半音低くなっている和音とも言えます。暗い印象を和音です。"},
                        {type: "text",text:"[増三和音(オーギュメントコード)]:長三和音の5度が半音高くなっている和音です。"},
                        {type: "text",text:"[減三和音(ディミニッシュコード)]:短三和音の5度が半音低くなっている和音です。"},
                    ]
               #入力されたコードネームの構成音を探す
                else
                    @data.each do |code|
                        if code.name == str #入力されたコードネームと一致したら
                            message = [
                                {type: "text",text: "#{code.first} #{code.third} #{code.fifth}"},
                                {type: "image",originalContentUrl: "#{code.url}",previewImageUrl: "#{code.url}"},
                            ]
                        break
                        
                        else                #DB上になかったら
                            message = {
                            type: "text",
                            text: "Not found"
                        }
                        end
                    end
                end
                client.reply_message(event["replyToken"], message)
                
           when Line::Bot::Event::MessageType::Location
               message = {
                   type: "location",
                   title: "あなたはここにいますか？",
                   address: event.message["address"],
                   latitude: event.message["latitude"],
                   longitude: event.message["longitude"]
               }
               client.reply_message(event["replyToken"], message)
           end
        end
        }
   
       head :ok
    end
end
