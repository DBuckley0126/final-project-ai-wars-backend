class Pixeling
  def movement
    
    if true
      return self.decide(false)
    end

  end
  
  def spawn_position
    {Y: 10}
  end
  
  def melee
    {attack: true}
  end

  
  def range
    {direction:"bakwards"}
  end
  
  def vision
    {active: "yes"}
  end 
  
  def health
    {reduce_health: 0}
  end
  
  def decide(arg)
    if arg
      return {X: 10, Y:10}
    else
      return {target:{X: 49, Y:10}, love: "yes"}
    end
  end
end
