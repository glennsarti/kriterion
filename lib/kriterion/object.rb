class Kriterion
  class Object
    def to_h(mode = :basic)
      raise 'Mode must be :basic or :full' unless %i[basic full].include? mode
      hash = {}

      # Add all instance variables to the hash without the @ sign
      instance_variables.each do |v|
        hash[v.to_s.gsub(/^@/, '')] = instance_variable_get(v.to_s)
      end

      if mode == :basic
        hash.reject do |k, _v|
          full_keys.include? k
        end
      elsif mode == :full
        expandable_keys.each do |key|
          hash[key.to_s] = send(key).map { |x| x.to_h(:full) }
        end
        hash
      end
    end

    def full_keys
      %w[
        sections
        items
        resources
        events
      ]
    end

    # Objects should deflault to not being expandable unless someone has
    # specifided it
    def expandable?
      false
    end

    def expandable_keys
      []
    end

    def find_section(name)
      sections ? sections.select { |s| s.name == name }[0] : nil
    end

    def compliance(objects)
      total         = objects.count
      compliant     = objects.count { |o| o.compliance['compliant'] }
      non_compliant = total - compliant
      percentage    = if total.zero?
                        0
                      else
                        compliant / total
                      end

      {
        'compliant' => percentage == 1,
        'events'    => {
          'percentage'    => percentage,
          'compliant'     => compliant,
          'non_compliant' => non_compliant,
          'total'         => total
        }
      }
    end
  end
end
