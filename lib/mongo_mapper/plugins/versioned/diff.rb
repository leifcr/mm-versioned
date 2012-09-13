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
          version1.data.keys.sort.each do |key|
            key_title = "<div class=\"single_diff\"><div class=\"key_title\">#{key.to_s}</div><div class=\"key_content\">"
            diffed =""
            Diffy::Diff.new("#{version1.content(key)}\n", "#{version2.content(key)}\n").each do |line|
              diffed += case line
                when /^\+/ then "<div class=\"add\">#{line.sub(/^./, '').chomp}</div>"
                when /^-/  then "<div class=\"del\">#{line.sub(/^./, '').chomp}</div>"
                else ""
              end #case
            end # Diffy
          ret += "#{key_title}#{diffed}</div></div>" unless diffed == ""
          end # version1.data.keys.sort.each
          ret +="</div>"
        end # diff_Html

        def diff_ascii(version1, version2)
          return "Nothing to diff with" if version1.nil? || version2.nil?
          ret = ""
          version1.data.keys.sort.each do |key|
            key_title = "Key: #{key.to_s}"
            key_title += "\n#{"-"*key_title.length}"
            diffed = ""
            Diffy::Diff.new("#{version1.content(key)}\n", "#{version2.content(key)}\n").each do |line|
              diffed += case line
                when /^\+/ then "#{line.chomp}\n"
                when /^-/  then "#{line.chomp}\n"
                else ""
              end #case
            end #Diffy
            ret += "#{key_title}\n#{diffed}\n" unless diffed == ""
          end # version1.data.keys.sort.each
          ret
        end # diff_ascii(version1, version2)

      end # Module Callbacks
    end # Module Versioned
  end # Module plugins
end # module MongoMapper

