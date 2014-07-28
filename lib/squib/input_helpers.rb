require 'squib/constants'

module Squib
  module InputHelpers

    def needs(opts, params)
      opts = Squib::SYSTEM_DEFAULTS.merge(opts)
      opts = rangeify(opts) if params.include? :range      
      opts = fileify(opts) if params.include? :file
      opts = fileify(opts, false, true) if params.include? :file_to_save
      opts = fileify(opts, true) if params.include? :files
      opts = colorify(opts) if params.include? :color
      opts = colorify(opts, true) if params.include? :nillable_color
      opts = dirify(opts) if params.include? :dir
      opts = dirify(opts, true) if params.include? :creatable_dir
      opts = fontify(opts) if params.include? :font
      opts = radiusify(opts) if params.include? :radius
      opts = svgidify(opts) if params.include? :svgid
      opts = formatify(opts) if params.include? :formats
      opts
    end
    module_function :needs

    def formatify(opts)
      opts[:format] = [opts[:format]].flatten
      opts
    end
    module_function :formatify

    def rangeify (opts)
      range = opts[:range]
      raise 'Range cannot be nil' if range.nil?
      range = 0..(@cards.size-1) if range == :all
      range = range..range if range.is_a? Integer
      if range.max > (@cards.size-1)
        raise "#{range} is outside of deck range of 0..#{@cards.size-1}"
      end
      opts[:range] = range
      opts
    end
    module_function :rangeify

    def fileify(opts, expand_singletons=false, allow_non_exist=false)
      opts[:file] = [opts[:file]] * @cards.size if expand_singletons
      files = [opts[:file]].flatten
      files.each do |file|
        unless File.exists? file || allow_non_exist
          raise "File #{File.expand_path(file)} does not exist!"
        end
      end
      opts
    end
    module_function :fileify

    def dirify(opts, allow_create=false)
      puts opts[:dir]
      return opts if Dir.exists?(opts[:dir])
      if allow_create
        Squib.logger.warn "Dir #{opts[:dir]} does not exist, creating it."
        Dir.mkdir opts[:dir]
        return opts 
      else
        raise "#{opts[:dir]} does not exist!"
      end
    end
    module_function :dirify


    def colorify(opts, nillable=false)
      if nillable # for optional color arguments like text hints
        opts[:color] = Cairo::Color.parse(opts[:color]) unless opts[:color].nil?
      else
        opts[:color] = Cairo::Color.parse(opts[:color])
      end
      opts
    end
    module_function :colorify

    def fontify (opts)
      opts[:font] = @font if opts[:font]==:use_set
      opts[:font] = Squib::SYSTEM_DEFAULTS[:default_font] if opts[:font] == :default
      opts 
    end
    module_function :fontify 

    def radiusify(opts)
      unless opts[:radius].nil?
        opts[:x_radius] = opts[:radius]
        opts[:y_radius] = opts[:radius]
      end
      opts
    end
    module_function :radiusify

    def svgidify(opts)
      unless opts[:id].nil?
        opts[:id] = '#' << opts[:id] unless opts[:id].start_with? '#'
      end
      opts
    end
    module_function :svgidify

    def xyify
      #TODO: Allow negative numbers that subtract from the card width & height.
    end

  end
end