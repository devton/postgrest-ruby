module PostgREST
  class Dataset
    include Enumerable

    attr_reader :connection, :table, :query, :headers

    def initialize(connection, table, query = Query.new, headers = {})
      @connection = connection
      @table = table
      @query = query
      @headers = headers
    end

    def each(&block)
      fetch_rows.each(&block)
    end

    def first
      fetch_rows(headers: headers.merge('Prefer' => 'plurality=singular'))
    end

    def order(*args)
      branch(query: query.append_order(*args))
    end

    def where(args = {})
      branch(query: query.filter(args))
    end

    private

    def fetch_rows(args = {})
      q = args.fetch(:query) { query }
      h = args.fetch(:headers) { headers }
      connection.table(table, q.encode, h)
    end

    def branch(args)
      self.class.new(connection, table, args.fetch(:query) { query },
        args.fetch(:headers) { headers })
    end
  end
end
