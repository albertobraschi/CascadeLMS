class FreshItems
  
  def FreshItems.fresh( course, limit, include_comments = true )
    # show the last X items (whatever they may be)
    blog_entries = Post.find(:all, :conditions => ["course_id=? and published=?",course.id,true], :order => "created_at DESC", :limit => limit  )
    documents = Document.find(:all, :conditions => ["course_id=? and published=? and folder=?",course.id, true,false], :order => "created_at DESC", :limit => limit  )
    time = Time.new
    assignments = Assignment.find(:all, :conditions => ["course_id=? and open_date<=? and close_date>=?",course.id,time,time], :order => "open_date DESC", :limit => limit  )
    
    recent_activity = Array.new
    blog_entries.each { |x| recent_activity << x }
    documents.each { |x| recent_activity << x }
    assignments.each { |x| recent_activity << x }
    
    if include_comments
      comments = Comment.find(:all, :conditions => ["course_id=?",course.id], :order => "created_at DESC", :limit => limit  )
      comments.each { |x| recent_activity << x }
    end
    
    # sort
    recent_activity.sort! do |a,b|
      if a.class.to_s.eql?("Assignment") && b.class.to_s.eql?("Assignment")
        a.open_date <=> b.open_date
      elsif a.class.to_s.eql?("Assignment")
        a.open_date <=> b.created_at
      elsif b.class.to_s.eql?("Assignment")
        a.created_at <=> b.open_date
      else
        a.created_at <=> b.created_at
      end
    end
    
    return recent_activity.reverse[0...limit]
  end
  
end