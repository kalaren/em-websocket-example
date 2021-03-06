require 'em-websocket'

class Notifier
  
  #class
  def self.set_n_array(n_array)
    @n_array = n_array
  end
    
  def self.notify(msg)
    @n_array.each do |n|
      puts "notifying"
      n.send msg
    end
  end
  
  #instance
  def initialize(ws)
    @is_open = false
    @ws = ws
  end
  
  def send(msg)
    if @is_open
      @ws.send msg
    end
  end
  
  def open
    @is_open = true
  end
  
end

n_array = Array.new
ws_array = Array.new

Notifier.set_n_array(n_array)

Thread.new {
  EM.run {

    EM::WebSocket.start(:host => "0.0.0.0", :port => 9999) do |ws|
      
        ws.onopen {
          puts "WebSocket connection open"
          ws.send "Hello Client"
          n = Notifier.new(ws)
          n.open
          n_array << n
          ws_array << ws
        }
        ws.onclose {
          puts "Connection closed"
          i = ws_array.index ws
          n_array.delete_at i
          ws_array.delete_at i
        }
        ws.onmessage { |msg|
          puts "Recieved message: #{msg}"
        }
    end
  }
}

while 1 do
  puts "enter msg:"
  STDOUT.flush  
  msg = gets.chomp
  Notifier.notify(msg)
end