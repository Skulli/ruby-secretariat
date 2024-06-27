module Secretariat
  module Export
    module Zugferd
      require "tmpdir"
      require "logger"
      require "open3"

      JAR_PATH = Secretariat.file_path("/lib/secretariat/export/bin/jar/Mustang-CLI-2.11.0.jar")

      def self.logger
        log_directory = File.expand_path("../../../../log", __FILE__)
        FileUtils.mkdir_p(log_directory) unless Dir.exist?(log_directory)

        @@logger ||= Logger.new(File.join(log_directory, "export.log"))
      end

      def self.convert_a1_to_a3_params(pdf_a1, output_file_path)
        "--action a3only --source #{pdf_a1} --out #{output_file_path}"
      end

      def self.combine_pdf_and_xml_params(source_pdf, source_xml, output_file_path, attachments_pathlist: '\"\"')
        "--action combine --source #{source_pdf} --source-xml #{source_xml} --out #{output_file_path} --format zf --version 2 --profile E --attachments #{attachments_pathlist}"
      end

      def self.call_jar(params)
        command = "java -Xmx1G -Dfile.encoding=UTF-8 -jar #{JAR_PATH} #{params}"

        logger.info("Executing command: #{command}")

        stdout, stderr, status = Open3.capture3(command)

        if status.success?
          logger.info("Command executed successfully")
        else
          logger.error("Command failed with error: #{stderr}")
          logger.error("Standard output: #{stdout}")
        end

        status.success?
      end

      def self.convert_and_combine(source_pdf:, source_xml:, output_filename: "output.pdf", output_dir: Dir.mktmpdir)
        pdfa3 = convert_to_a3(source_pdf: source_pdf)

        combine_files(source_pdf: pdfa3, source_xml: source_xml, output_filename: output_filename, output_dir: output_dir)
      end

      def self.convert_to_a3(source_pdf:, output_filename: "a3output.pdf", output_dir: Dir.mktmpdir)
        output_file_path = File.join(output_dir, output_filename)

        begin
          result = call_jar(convert_a1_to_a3_params(source_pdf, output_file_path))

          unless result
            logger.error("Failed to convert pdf")
            raise "Failed to convert pdf"
          end

          logger.info("Successfully converted PDF to PDFA/3: #{output_file_path}")

          output_file_path
        rescue => e
          logger.error("Error during file conversion: #{e.message}")
          raise e
        ensure
          File.delete(output_file_path) if output_dir == Dir.tmpdir && File.exist?(output_file_path)
        end
      end

      def self.combine_files(source_pdf:, source_xml:, output_filename: "output.pdf", output_dir: Dir.mktmpdir)
        output_file_path = File.join(output_dir, output_filename)

        begin
          result = call_jar(combine_pdf_and_xml_params(source_pdf, source_xml, output_file_path))

          unless result
            logger.error("Failed to combine files")
            raise "Failed to combine files"
          end

          logger.info("Successfully combined files into #{output_file_path}")

          output_file_path
        rescue => e
          logger.error("Error during file combination: #{e.message}")
          raise e
        ensure
          File.delete(output_file_path) if output_dir == Dir.tmpdir && File.exist?(output_file_path)
        end
      end
    end
  end
end
