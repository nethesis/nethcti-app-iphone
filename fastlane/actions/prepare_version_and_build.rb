module Fastlane
  module Actions
    module SharedValues
      CURRENT_PROJECT_VERSION_STRING = :CURRENT_PROJECT_VERSION_STRING
      UPDATED_PROJECT_BUILD_NUMBER = :UPDATED_PROJECT_BUILD_NUMBER
    end

    class PrepareVersionAndBuildAction < Action
      def self.run(params)
        
        # For more information, visit:
        # 1. https://docs.fastlane.tools/actions/get_version_number/
        # 2. https://docs.fastlane.tools/actions/latest_testflight_build_number/
        # 3. https://docs.fastlane.tools/actions/increment_build_number/
        
        version_string = other_action.get_version_number(
          xcodeproj: "linphone.xcodeproj",
          target: "NethCTI"
        )
        UI.message("Returned #{Action.lane_context[SharedValues::VERSION_NUMBER]}/#{version_string} version_string") if params[:verbose]
        # Update the shared value.
        Actions.lane_context[SharedValues::CURRENT_PROJECT_VERSION_STRING] = version_string

        tf_build = other_action.latest_testflight_build_number(
          version: version_string,
          initial_build_number: 0
        )
        UI.message("Returned #{Action.lane_context[SharedValues::LATEST_TESTFLIGHT_VERSION]} version on Testflight and #{Action.lane_context[SharedValues::LATEST_TESTFLIGHT_BUILD_NUMBER]}/#{tf_build} build number on Testflight") if params[:verbose]
        # Update the shared value.
        new_build_number = tf_build + 1 # Obviously increment the latest build number. (tf_build || 0) + 1.
        Actions.lane_context[SharedValues::UPDATED_PROJECT_BUILD_NUMBER] = new_build_number

        other_action.increment_build_number(
          build_number: new_build_number, 
          xcodeproj: "linphone.xcodeproj"
        )

        commit_message = "Version bump to made #{version_string}(##{new_build_number}) by Fastlane."
        other_action.commit_version_bump(
          force: true,
          message: commit_message,
          xcodeproj: "linphone.xcodeproj" # optional, if you have multiple Xcode project files, you must specify your main project here
        )

        # Send a system notification.
        other_action.notification(
          app_icon: "./Resources/images.xcassets/AppIcon.appiconset/1024.png",
          content_image: "./Resources/images.xcassets/AppIcon.appiconset/1024.png",
          title: "NethCTI Fastlane",
          subtitle: "Incremented build number",
          message: commit_message
        ) if params[:verbose]

        return tf_build

      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Increment the build number without changing the version string."
      end

      def self.details
        # Optional:
        # this is your chance to provide a more detailed description of this action
        [
          "If you have to manage two different versions on two different branches, with this you can forget to change it each time.",
          "You can use this action inside another one. Works only with iOS or macOS.",
          "After all those jobs, it commit all modified files."
        ].join("/n")
      end

      def self.available_options
        # Define all options your action supports.

        # Below a few examples
        [
          FastlaneCore::ConfigItem.new(key: :verbose,
                                       env_name: "VERBOSE_LOGS", # The name of the environment variable
                                       description: "Set the verbosity level of the action: false value will prevent any output", # a short description of this parameter
                                       default_value: true, # the default value if the user didn't provide one
                                       optional: true,
                                       is_string: false # true: verifies the input is a string, false: every kind of value
                                       ) 
        ]
      end

      def self.output
        # Define the shared values you are going to provide
        # Example
        [
          ['CURRENT_PROJECT_VERSION_STRING', 'The current project version string, that will be equal to VERSION_NUMBER.'],
          ['UPDATED_PROJECT_BUILD_NUMBER', 'The current project build number, that will be equal to LATEST_TESTFLIGHT_BUILD_NUMBER.']
        ]
      end

      def self.return_value
        # If your method provides a return value, you can describe here what it does
        "Integer representation of the latest build number uploaded to TestFlight plus 1"
      end

      def self.return_type
        :int
      end

      def self.example_code
        ['prepare_version_and_build']
      end

      def self.sample_return_value
        2
      end

      def self.authors
        # So no one will ever forget your contribution to fastlane :) You are awesome btw!
        ["Daniele-Tentoni"]
      end

      def self.is_supported?(platform)
        # you can do things like
        #
        #  true
        #
        #  platform == :ios
        #
        #  [:ios, :mac].include?(platform)
        #
        [:ios, :mac].include?(platform)
      end

      def self.category
        :source_control
      end
    end
  end
end
