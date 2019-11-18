require 'spec_helper'

describe DataFixup::BackfillNulls do
  context '.run' do
    before do
      @course1 = create(:course_config, course_id: 1234, tardy_weight: nil)
      @course2 = create(:course_config, course_id: 1235, tardy_weight: 0.8)
    end

    it 'replaces null values of "field" with the new value' do
      expect {
        DataFixup::BackfillNulls.run(CourseConfig, :tardy_weight, new_value: 0.5)
      }.to change { @course1.reload.tardy_weight }.from(nil).to(0.5)
    end

    it 'does not replace not-null values of "field"' do
      expect {
        DataFixup::BackfillNulls.run(CourseConfig, :tardy_weight, new_value: 0.5)
      }.not_to change { @course2.reload.tardy_weight }.from(0.8)
    end
  end
end
