class DocumentChunk < ApplicationRecord
  belongs_to :organization
  belongs_to :source, polymorphic: true

  has_neighbors :embedding, dimensions: 1536

  validates :content, presence: true
  validates :source_type, :source_id, presence: true
  validates :source_id, uniqueness: { scope: :source_type }
end
