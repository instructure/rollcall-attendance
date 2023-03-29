class JsonResponse < OpenStruct
  def as_json(*args)
    super.as_json['table']
  end
end
