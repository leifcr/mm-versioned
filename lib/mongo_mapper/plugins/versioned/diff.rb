module MongoMapper
  module Plugins
    module Versioned
      module Diff
        def diff(version_number1, version_number2, format = :html)
          version1 = self.version_at(version_number1)
          version2 = self.version_at(version_number2)
          return diff_ascii(version1, version2) if format == :ascii 
          diff_html(version1, version2) 
        end

        def diff_html(version1, version2)
          return "<div class=\"diff error\">Cannot diff with a nil object...</div>" if version1.nil? || version2.nil?
          ret = "<div class=\"diff\">"
          version1.data.keys.each do |key|
            Diffy::Diff.new("#{version1.content(key)}\n", "#{version2.content(key)}\n").each do |line|
              diffed = case line
                 when /^\+/ then "<div class=\"add\">#{line.sub(/^./, '').chomp}</div>"
                 when /^-/  then "<div class=\"del\">#{line.sub(/^./, '').chomp}</div>"
                 else nil
               end
              ret += "<div class=\"single_diff\"><div class=\"key_title\">#{key.to_s}</div>#{diffed}</div>" unless diffed.nil?
            end
          end
          ret +="</div>"
        end

        def diff_ascii(version1, version2)
          return "Nothing to diff with" if version1.nil? || version2.nil?
          ret = ""
          version1.data.keys.each do |key|
            title = "Key: #{key.to_s}"
            ret += "#{title}\n#{"-"*title.length}\n"
            Diffy::Diff.new("#{version1.content(key)}\n", "#{version2.content(key)}\n").each do |line|
              ret += "#{line.chomp}\n"
            end
            ret += "\n"
          end
          ret
        end

      end # Module Callbacks
    end # Module Versioned
  end # Module plugins
end # module MongoMapper

