module Zf::Utils
  def to_upper_camel_case(str)
    str
      .split('/')
      .map { |part| part.split('_').map(&:capitalize).join }
      .join('::')
  end

  extend self
end
