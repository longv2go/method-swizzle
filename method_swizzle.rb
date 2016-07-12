module MethodSwizzle
  def self.method_before(clazz, method, &block)
    method_swizzle(clazz, method) do |binded, *args|
      block.call(*args)
      binded.call(*args)
    end
  end

  def self.method_after(clazz, method, &block)
    method_swizzle(clazz, method) do |binded, *args|
      binded.call(*args)
      block.call(*args)
    end
  end

  def self.method_swizzle(clazz, method, &block)
    begin
      orgin_method = clazz.instance_method(method)
    rescue NameError => e
      Log.w "Not found method '#{method}' in '#{clazz}'"
      return
    end

    clazz.class_eval do
      define_method(method) do |*args|
        binded = orgin_method.bind(self) # 这个self是当前block执行的时候bind的self，不是方法定义所在的self
        block.call(binded, *args)
      end
    end
  end
end
