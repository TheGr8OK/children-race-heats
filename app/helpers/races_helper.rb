module RacesHelper
  def drawer(title, &block)
    content_for(:drawer_title, title)
    content_for(:drawer_content, content_tag(:div, capture(&block)))
    turbo_stream.replace "drawer", template: "layouts/drawer"
  end

  def race_status(race)
    content_tag(:div, class: "flex items-center gap-2") do
      concat render_status_icon(race)
      concat race.status.humanize
    end
  end

  def student_place(membership)
    content_tag(:div, class: "flex items-center gap-2") do
      concat render_place_prefix(membership.place)
      concat membership.student.full_name
    end
  end

  private

  def render_place_prefix(place)
    content_tag(:div, class: "w-16 h-16 flex items-center justify-center") do
      case place
      when 1
        render "icons/first_place"
      when 2
        render "icons/second_place"
      when 3
        render "icons/third_place"
      else
        # Convert number to ordinal (4th, 5th, etc.)
        content_tag(:span, "#{place}#{ordinal_suffix(place)}", class: "font-medium")
      end
    end
  end

  def ordinal_suffix(number)
    return 'th' if [11, 12, 13].include?(number % 100)
    
    case number % 10
    when 1 then 'st'
    when 2 then 'nd'
    when 3 then 'rd'
    else 'th'
    end
  end

  def render_status_icon(race)
    if race.live?
      content_tag(:div, class: "w-2 h-2 text-lime-400") do
        render "icons/circle"
      end
    else
      content_tag(:div, class: "w-3 h-3 text-blue-500") do
        render "icons/check"
      end
    end
  end
end

