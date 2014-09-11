module CallDetails

  private


  # Max. delays calculation

  def max_delay_hash
    Numbers.conf['languages'].each_with_object({}) { |lang, hash|
      hash[lang[0]] = max_delay_per_lang(lang[0])
    }
  end

  def max_delay_per_lang(lang)
    Numbers.conf['skills'].each_with_object({}) { |skill, hash|
      hash[skill[0]] = max_delay_per_skill(skill[0], lang).round
    }
  end

  def max_delay_per_skill(skill, lang)
    time_now - (call_queued_times_per_skill(skill, lang).first || time_now)
  end

  def call_queued_times_per_skill(skill, lang)
    queued_calls_per_skill(skill, lang).map { |c| c.queued_at }.sort
  end


  # Avg. delays calculation

  def average_delay_hash
    Numbers.conf['languages'].each_with_object({}) { |lang, hash|
      hash[lang[0]] = average_delay_per_lang(lang[0])
    }
  end

  def average_delay_per_lang(lang)
    Numbers.conf['skills'].each_with_object({}) { |skill, hash|
      hash[skill[0]] = average_delay_per_skill(skill[0], lang)
    }
  end

  def average_delay_per_skill(skill, lang)
    queued_times = call_queued_times_per_skill(skill, lang)
    return 0 if queued_times.size == 0

    (queued_times.inject(0) { |sum, t|
      sum += time_now - t
    } / call_queued_times.size).round
  end


  # Queued calls aggregation

  def queued_calls_hash
    Numbers.conf['languages'].each_with_object({}) { |lang, hash|
      hash[lang[0]] = queued_calls_per_lang(lang[0])
    }
  end

  def queued_calls_per_lang(lang)
    Numbers.conf['skills'].each_with_object({}) { |skill, hash|
      hash[skill[0]] = queued_calls_per_skill(skill[0], lang).size
    }
  end

  def queued_calls_per_skill(skill, lang)
    queued_calls.select { |c| c.skill == skill && c.language == lang }
  end


  # Dispatched calls aggregation

  def dispatched_calls_hash
    Numbers.conf['languages'].each_with_object({}) { |lang, hash|
      hash[lang[0]] = dispatched_calls_per_lang(lang[0])
    }
  end

  def dispatched_calls_per_lang(lang)
    Numbers.conf['skills'].each_with_object({}) { |skill, hash|
      hash[skill[0]] = dispatched_calls_per_skill(skill[0], lang).keys.size
    }
  end

  def dispatched_calls_per_skill(skill, lang)
    dispatched_calls.select { |c| c.skill == skill && c.language == lang }
                    .group_by { |c| c.call_tag }
  end
end
