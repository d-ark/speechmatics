# -*- encoding: utf-8 -*-

require 'mimemagic'

module Speechmatics
  class User::Jobs < API
    include Configuration

    def create(params={})
      puts "Memory usage before attach: #{`ps ax -o pid,rss | grep -E "^[[:space:]]*#{$$}"`.strip.split.map(&:to_i)}"
      attach_audio(params)
      puts "Memory usage after attach: #{`ps ax -o pid,rss | grep -E "^[[:space:]]*#{$$}"`.strip.split.map(&:to_i)}"
      attach_text(params) if params[:text_file]
      puts "Memory usage before set_mode: #{`ps ax -o pid,rss | grep -E "^[[:space:]]*#{$$}"`.strip.split.map(&:to_i)}"
      set_mode(params)
      puts "Memory usage after set_mode: #{`ps ax -o pid,rss | grep -E "^[[:space:]]*#{$$}"`.strip.split.map(&:to_i)}"
      super
    end

    def transcript(params={})
      self.current_options = current_options.merge(args_to_options(params))
      request(:get, "#{base_path}/transcript")
    end

    def alignment(params={})
      self.current_options = current_options.merge(args_to_options(params))
      request(:get, "#{base_path}/alignment", {:options => {'allow_text' => true}})
    end

    def set_mode(params={})
      unless params[:text_file]
        params[:model] ||= 'en-US'
      end
      params
    end

    def attach_audio(params={})
      file_path = params[:data_file]
      raise "No file specified for new job, please provide a :data_file value" unless file_path
      #raise "No file exists at path '#{file_path}'" unless File.exists?(file_path)

      content_type = "" # params[:content_type] || MimeMagic.by_path(file_path).to_s
      # raise "No content type specified for file, please provide a :content_type value" unless content_type
      # raise "Content type for file '#{file_path}' is not audio or video, it is '#{content_type}'." unless (content_type =~ /audio|video/)
      puts "original_filename #{params[:original_filename]}"
      params[:data_file] = Faraday::UploadIO.new(file_path, content_type, params[:original_filename])
      params
    end

    def attach_text(params={})
      file_path = params[:text_file]
      # raise "No file exists at path '#{file_path}'" unless File.exists?(file_path)
      params[:text_file] = Faraday::UploadIO.new(file_path, "text/plain; charset=utf-8", 'text.txt')
      params
    end

  end
end
