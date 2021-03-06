class CourseCreator
  
  def initialize( user, crns, subjects, format )
    @user = user
    @crns = crns
    @subjects = subjects
    @format = format
  end

  
  def reconcile
    status = ""
    created = 0
    
    terms = Array.new
    # first check term
    @crns.each do |crn|
      term = Term.find(:first, :conditions => ["term = ?", full_term_id(crn) ])
      if term.nil? 
        # need to create & activate (assuming it is the most current)
        all_terms = Term.find(:all, :conditions => ["current = ?", true] )
        all_terms.each do |oldterm|
          oldterm.current = false
          oldterm.save
        end
        term = Term.new
        term.term = full_term_id(crn)
        term.year = year(crn).to_i
        term.semester = "#{term_id(crn)} #{year(crn)}"
        term.current = true
        term.save
        
        status = "#{status} Created, and made current, the newly discovered term: #{term.term}.<br/>"
      end
      # for they are lined up with the CRNs
      terms << term
    end
    
    ## then verify that (1) the courses exist and (2) this use is an instructor
    @crns.each_index do |i|
      crn_txt = @crns[i]
      description = @subjects[i]
      crn = Crn.find(:first, :conditions => ["crn = ?", crn_txt] )
      
      # if it doesn't exist
      if crn.nil?
        # create the crn
        crn = Crn.new
        crn.crn = crn_txt
        crn.name = "#{crn_txt} - Could not figure out automatically"
        crn.title = "created for #{@user.uniqueid}"
        crn.save
      end
        
      if crn.courses.size == 0
        # create the course if there is not a course associated with this CRN
        course = Course.new
        course.term = terms[i]
        course.title = crn.name
        course.short_description = crn.title
        course.open = true
        
        course.crns << crn
        courseuser = CoursesUser.new
        courseuser.user = @user
        courseuser.course = @course
        courseuser.course_student = false
        courseuser.course_instructor = true
        
        course.courses_users << courseuser
        course.save
        status = "#{status} Created, and made you the instructor of, course: #{crn.crn}, #{crn.name}.<br/>"
        
        created = created.next
      end
    end  
    
    status = nil if status.eql?('')
    if created > 0
      status = "#{status} Please visit the Instructor, Course Information page for each course of your to enter the appropraite course title and description.   We recommend doing this before merging courses." 
    end
    return status
  end
  
  def term_id( crn )
    range_by_char( crn, @format, 'T' )
  end
  
  def year( crn )
    range_by_char( crn, @format, 'Y' )
  end
  
  def full_term_id( crn )
    "#{year(crn)}#{term_id(crn)}"
  end
  
  def range_by_char( str, format, char )
    index_b = format.index(char)
    index_e = format.length - format.reverse.index(char )
    
    #puts index_b
    #puts index_e
    if index_b >= 0 && index_e >= 0 && index_e > index_b 
      str[index_b...index_e]
    else
      ''
    end
  end
  
  private :range_by_char
  
end