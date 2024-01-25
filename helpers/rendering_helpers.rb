module RenderingHelpers
  def page_title
    if current_log
      "Logs Buddy - #{current_log.name}"
    else
      "Logs Buddy - Your Personal and Sharable Logs"
    end
  end
end