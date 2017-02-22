module Fluent
  class StackdriverV1MetricsOutput < BufferedOutput

    Plugin.register_output('stackdriver-v1_metrics', self)

    def initialize
      super
      require 'stackdriver'
    end

    config_param :api_key, :string, :default => nil
    config_param :instance_id, :string, :default => nil
    config_param :counter_maps, :hash, :default => {}
    config_param :counter_defaults, :array, :default => []
    config_param :metric_maps, :hash, :default => {}
    config_param :metric_defaults, :array, :default => []

    def configure(conf)
      super(conf) {
        @api_key = conf.delete('api_key')
        @instance_id = conf.delete('instance_id')
        @counter_maps = conf.delete('counter_maps')
        @counter_defaults = conf.delete('counter_defaults')
        @metric_maps = conf.delete('metric_maps')
        @metric_defaults = conf.delete('metric_defaults')
      }

      @base_entry = {}
      @base_entry['instance'] = @instance_id if @instance_id

    end

    def format(tag, time, record)
      # Everything goes into the buffer in a JSON format.
      { 'tag' => tag, 'time' => time, 'record' => record }.to_json + "\n"
    end

    def write(chunk)

      timestamp = Time.now.to_i
      data = []

      count_data = {}
      metric_data = {}

      chunk.read.chomp.split("\n").each do |line|
        event = JSON.parse(line)

        @counter_maps.each do |k,v|
          if eval(k)
            name = eval(v) 
            count_data[name] ||= 0
            count_data[name] += 1
          end
        end

        @metric_maps.each do |k,v|
          if eval(k)
            if eval(v)
              data << @base_entry.merge({ 'collected_at' => event['time'].to_i }).merge(eval(v))
            end
          end
        end

      end

      count_data.each do |name,value|
        data << @base_entry.merge({
          'name' => name,
          'value' => value,
          'collected_at' => timestamp
        })
      end

      @counter_defaults.each do |e|
        if not count_data.key?(e['name'])
          data << @base_entry.merge({'collected_at' => timestamp}).merge(e)
        end
      end

      @metric_defaults.each do |e|
        if not metric_data.key?(e['name'])
          data << @base_entry.merge({'collected_at' => timestamp}).merge(e)
        end
      end

      if data
        StackDriver.init @api_key
        StackDriver.send_multi_metrics data
      end

    end

  end

end
