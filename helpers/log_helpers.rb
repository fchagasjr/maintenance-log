module LogHelpers
  # Returns the assemblies for the current log
  def assemblies
    @assemblies ||= current_log&.assemblies
  end

  # Returns the entities for the current log
  def entities
    @entities ||= current_log&.entities
  end

  # Returns the request records for the current log
  def request_records
    @request_records ||= RequestRecord.joins(:entity)
                                      .where(entity: { assembly_id: assemblies&.ids })
  end
end