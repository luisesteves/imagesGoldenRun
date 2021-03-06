require 'imatcher'
require 'fastlane/action'
require 'fileutils'
require_relative '../helper/imagesgoldenrun_helper'

module Fastlane
  module Actions
    class ImagesgoldenrunAction < Action
      def self.run(params)

        UI.message("Starting...".green)

        differencesRootFolder = "imagesGoldenRunReport"
        differencesFolder = "differences"
        differencesPath = "#{differencesRootFolder}/#{differencesFolder}"
        UI.message("differencesPath: #{differencesPath}".green)   
             
        FileUtils.mkdir_p(differencesPath)

        Dir.foreach(differencesPath) do |f|
          fp = File.join(differencesPath, f)
          File.delete(fp) if !File.directory?(fp)
        end

        #html report
        goldenRunReport = "<html><body><h2>Images Gonden Run results<h2><p><htmlImages></body></html>"
        htmlImages = ""
        imgExtension = ".png"
        hasDifferences = false

        goldenRunImagesNames = Dir.entries(params[:goldenRunLoc]).select {|f| f.end_with?(imgExtension)}

        goldenRunImagesNames.each do |imageName|
          UI.message("Comparing #{imageName}".green)

          imgFullPathGolden = "#{params[:goldenRunLoc]}/#{imageName}"
          UI.message("   full path: #{imgFullPathGolden}".green)

          #find the full name of the result file
          resultImageName = Dir.entries(params[:resultLoc]).select {|f| f.start_with? imageName.gsub(imgExtension, "") }.first

          imgFullPathResult = "#{params[:resultLoc]}/#{resultImageName}"

          excludeArea = params[:excludeArea].gsub(/\s+/, '').split(",").map { |e| e.to_i }
          res = Imatcher.compare(imgFullPathGolden, imgFullPathResult, exclude_rect: excludeArea)
          r = res.match?
          unless r
            hasDifferences = true
            UI.message("   Has differences".green)
            #save the result image
            imagesGoldenRunReportFullPath = "#{differencesPath}/#{imageName}"
            res.difference_image.save(imagesGoldenRunReportFullPath)

            #html report
            htmlImages += "<h2>#{imageName}</h2><img src='#{differencesFolder}/#{imageName}' style='height:50%;' onclick='window.open(this.src)'>"
          else 
            UI.message("   No differences".green)
          end
        end

        UI.message("Creating report".green)
        #html report
        goldenRunReport.gsub!("<htmlImages>", hasDifferences ? htmlImages : "<h3>No differences found<h3>")
        File.open("#{differencesRootFolder}/report.html", "w") { |file| file.write(goldenRunReport) }

        if hasDifferences && params[:failWhenDiffs]
          UI.message("Error: ".red + "Some differences found".red)
          raise Exception
        end
        UI.message("Done".green)
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
                                         optional: false),
            FastlaneCore::ConfigItem.new(key: :failWhenDiffs,
                                         description: 'Area for the exclusion',
                                         optional: true,
                                         default_value: false)
        ]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
