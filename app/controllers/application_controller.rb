class ApplicationController < ActionController::API
    require 'jwt'
      def secret_key
        'dskuhfjdsg'
      end
    #   takes in a payload which is an object
      def encode(payload) 
        JWT.encode(payload, secret_key, 'HS256')
      end
      #   takes in a token which is an string
      def decode(token)
        JWT.decode(token, secret_key, true, { algorithm: 'HS256' })[0]
      rescue StandardError
        puts 'FAILED'
      end

      def create
        user = User.find_by(email: params[:email])
        if user&.authenticate(params[:password])
          payload = { "exp": Time.now.to_i + 2.week, 'user_id': user.id }
          token = encode(payload)
          render json: {user: user , token: token}
        else
          render json: {
            message: 'Incorrect Username/Password'
          }
        end
      end

      def index
        token = params[:token]
        # token = request.headers['Authentication'].split(' ')[1] 
        payload = decode(token)
        user = User.find(payload['user_id'])
        if user
            render json: user
        else
            render json: {message: "INVALID TOKEN"}
        end
      end

    #   def user_messages
    #     token = params[:token]
    #     payload = decode(token)
    #     user = User.find(payload['user_id'])
    #     render json: user.messages
    #   end
end
