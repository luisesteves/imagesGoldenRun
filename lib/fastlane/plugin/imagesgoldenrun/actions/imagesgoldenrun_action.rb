require 'imatcher'
require 'fastlane/action'
require 'fileutils'
require_relative '../helper/imagesgoldenrun_helper'

module Fastlane
  module Actions
    class ImagesgoldenrunAction < Action
      def self.run(params)

        differencesPath = "imagesGoldenRun/differences"
        FileUtils.mkdir_p(differencesPath)

        Dir.foreach(differencesPath) do |f|
          fp = File.join(differencesPath, f)
          File.delete(fp) if !File.directory?(fp)
        end

        goldenRunReport = "<html><body><htmlImages></body></html>"
        htmlImages = ""
        goldenRunImagesNames = Dir.entries(params[:goldenRunLoc]).select {|f| f.end_with? ".png"}
        goldenRunImagesNames.each do |imageName|
          imgG = "#{params[:goldenRunLoc]}/#{imageName}"
          imgR = "#{params[:resultLoc]}/#{imageName}"
          excludeArea = params[:excludeArea].gsub(/\s+/, '').split(",").map { |e| e.to_i }
          res = Imatcher.compare(imgG, imgR, exclude_rect: excludeArea)
          r = res.match?
          unless r
            img = "#{differencesPath}/#{imageName}"
            res.difference_image.save(img)
            htmlImages += "<h2>#{imageName}</h2><img src='../#{img}' style='height:50%;' onclick='window.open(this.src)'>"
          end
        end
        goldenRunReport.gsub!("<htmlImages>", htmlImages)
        File.open("imagesGoldenRun/report.html", "w") { |file| file.write(goldenRunReport) }
      end

      def self.description
        "this allows comparing images from a golden run with the actual results"
      end

      def self.authors
        ["Luís Esteves"]
      end

      def self.return_value
        # If your method provides a return value, you can describe here what it does
      end

      def self.details
        # Optional:
        "this allows comparing images from a golden run with the actual results"
      end

      def self.available_options
        [
            FastlaneCore::ConfigItem.new(key: :goldenRunLoc,
                                         description: 'Golden run images location',
                                         optional: false),
            FastlaneCore::ConfigItem.new(key: :resultLoc,
                                         description: 'Results images location',
                                         optional: false),
            FastlaneCore::ConfigItem.new(key: :excludeArea,
                                         description: 'Results images location',
                                         optional: false)
        ]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
