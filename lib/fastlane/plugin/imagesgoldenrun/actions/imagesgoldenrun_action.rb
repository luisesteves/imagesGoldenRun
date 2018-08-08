require 'imatcher'
require 'fastlane/action'
require 'fileutils'
require_relative '../helper/imagesgoldenrun_helper'

module Fastlane
  module Actions
    class ImagesgoldenrunAction < Action
      def self.run(params)

        differencesFolder = "imagesGoldenRunReport"
        differencesPath = "#{differencesFolder}/differences"
        FileUtils.mkdir_p(differencesPath)

        Dir.foreach(differencesPath) do |f|
          fp = File.join(differencesPath, f)
          File.delete(fp) if !File.directory?(fp)
        end

        #html report
        goldenRunReport = "<html><body><htmlImages></body></html>"
        htmlImages = ""
        
        goldenRunLoc = File.expand_path(File.join(Dir.pwd, params[:goldenRunLoc]))
        goldenRunImagesNames = Dir.entries(goldenRunLoc).select {|f| f.end_with? ".png"}
        goldenRunImagesNames.each do |imageName|

          imgFullPathG = "#{params[:goldenRunLoc]}/#{imageName}"
          imgFullPathR = "#{params[:resultLoc]}/#{imageName}"
          excludeArea = params[:excludeArea].gsub(/\s+/, '').split(",").map { |e| e.to_i }
          res = Imatcher.compare(imgFullPathG, imgFullPathR, exclude_rect: excludeArea)
          r = res.match?
          unless r
            #save the result image
            imagesGoldenRunReportFullPath = "#{differencesPath}/#{imageName}"
            res.difference_image.save(imagesGoldenRunReportFullPath)

            #html report
            htmlImages += "<h2>#{imageName}</h2><img src='../#{imagesGoldenRunReportFullPath}' style='height:50%;' onclick='window.open(this.src)'>"
          end
        end

        #html report
        goldenRunReport.gsub!("<htmlImages>", htmlImages)
        File.open("#{differencesFolder}/report.html", "w") { |file| file.write(goldenRunReport) }
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
                                         description: "Golden run images relative path (e.g. 'images/goldenRun')",
                                         optional: false),
            FastlaneCore::ConfigItem.new(key: :resultLoc,
                                         description: "Results images relative path (e.g. 'images/results)",
                                         optional: false),
            FastlaneCore::ConfigItem.new(key: :excludeArea,
                                         description: 'Area for the exclusion',
                                         optional: false)
        ]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
