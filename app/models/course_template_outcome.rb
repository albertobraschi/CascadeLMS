class CourseTemplateOutcome < ActiveRecord::Base
  validates_presence_of :outcome
  
  belongs_to :course_template
  has_and_belongs_to_many :program_outcomes
  
  def child_outcomes
    CourseTemplateOutcome.find(:all, :conditions => ["parent = ?",self.id], :order => "position ASC")
  end
  
  def mapped_to_program_outcome?( prog_outcome_id )
    self.program_outcomes.each do |i|  
      return true if i.id == prog_outcome_id
    end
    return false
  end
  
end
