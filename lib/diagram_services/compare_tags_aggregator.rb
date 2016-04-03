module DiagramServices
  class CompareTagsAggregator

    attr_reader :tag

    def initialize(tag)
      @tag = tag
    end

    def test_method
      diagram_set = []
      # Partial Count: number of times a tag is used on the same note
      # as the tag being compared
      partial_count = related_tags_with_partial_counts

      # Full Count: total number of times a tag is used
      full_count = related_tags_with_full_counts

      full_count.each do |related_tag|
        diagram_set << {sets: [related_tag.name], size: related_tag.full_count}
      end
      partial_count.each do |related_tag|
        diagram_set << {sets: [tag.name, related_tag.name], size: related_tag.count}
      end
      diagram_set
    end

    def related_tags_with_partial_counts
      @related_tags ||= get_related_tags_with_partial_counts
    end

    def related_tags_with_full_counts
      tag_ids = get_related_tags_with_partial_counts.map(&:tag_id)
      @full_counts ||= get_related_tags_with_full_counts(tag_ids)
    end

    def get_related_tags_with_full_counts(tag_ids)
      Tagging.where(tag_id: tag_ids)
        .joins(:tag)
        .select('COUNT(tag_id) as full_count, tag_id, name')
        .group(:tag_id, :name)
    end

    def get_related_tags_with_partial_counts
      note_ids = tag.taggings.pluck(:note_id)
      Tagging.where(note_id: note_ids)
        .joins(:tag)
        .select('COUNT(taggings.tag_id) as count, taggings.tag_id, tags.name')
        .group(:tag_id, :name)
        .order('count desc')
        .limit(11)
    end
  end
end
