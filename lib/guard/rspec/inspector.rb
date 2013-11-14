module Guard
  class RSpec
    class Inspector
      attr_accessor :options, :failed_paths, :spec_paths

      def initialize(options = {})
        @options = Options.with_defaults(options)
        @failed_paths = []
        @spec_paths = @options[:spec_paths]
      end

      def paths(paths = nil)
        if paths
          _paths(paths)
        else
          spec_paths
        end
      end

      def clear_paths(paths = nil)
        if paths
          @failed_paths -= paths
        else
          @failed_paths.clear
        end
      end

      private

      def _temporary_file_path
        Guard::RSpec::Formatters::Formatter::TEMPORARY_FILE_PATH
      end

      def _paths(paths)
        _focused_paths || if options[:keep_failed]
          @failed_paths += _clean(paths)
        else
          _clean(paths)
        end
      end

      def _focused_paths
        return nil unless options[:focus_on_failed]
        File.open(_temporary_file_path) { |f| f.read.split("\n")[1..11] }
      rescue
        nil
      ensure
        File.exist?(_temporary_file_path) && File.delete(_temporary_file_path)
      end

      def _clean(paths)
        paths.uniq!
        paths.compact!

        spec_dirs   = _select_only_spec_dirs(paths)
        spec_files  = _select_only_spec_files(paths)
        paths       = spec_dirs + spec_files

        paths
      end

      def _select_only_spec_dirs(paths)
        paths.select { |p| File.directory?(p) || spec_paths.include?(p) }
      end

      def _select_only_spec_files(paths)
        spec_files = spec_paths.collect { |path| Dir[File.join(path, "**{,/*/**}", "*[_.]spec.rb")] }
        feature_files = spec_paths.collect { |path| Dir[File.join(path, "**{,/*/**}", "*.feature")] }
        files = (spec_files + feature_files).flatten
        paths.select { |p| files.include?(p) }
      end

    end
  end
end
