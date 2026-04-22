# Idempotent dev seed: two organizations, two users, mixed roles.
# Running this under RLS requires session GUC to be set. We bypass via
# ActiveRecord::Base.transaction with a superuser connection (dev role is
# currently superuser; see db/migrate/20260422131515_create_rls_scaffold.rb).

acme = Organization.find_or_create_by!(slug: "acme") do |org|
  org.name = "Acme Corp"
end

globex = Organization.find_or_create_by!(slug: "globex") do |org|
  org.name = "Globex Industries"
end

alice = User.find_or_create_by!(email_address: "alice@tracklane.dev") do |u|
  u.password = "password"
  u.password_confirmation = "password"
end

bob = User.find_or_create_by!(email_address: "bob@tracklane.dev") do |u|
  u.password = "password"
  u.password_confirmation = "password"
end

Membership.find_or_create_by!(user: alice, organization: acme)   { |m| m.role = :admin }
Membership.find_or_create_by!(user: alice, organization: globex) { |m| m.role = :viewer }
Membership.find_or_create_by!(user: bob,   organization: globex) { |m| m.role = :manager }

[
  [ acme,   "Website redesign", "website-redesign", "Refresh the marketing site with the new brand system." ],
  [ acme,   "Mobile app v2",    "mobile-app-v2",    "Native iOS and Android, feature parity with web." ],
  [ globex, "Payments gateway", "payments-gateway", "Switch payments provider and add Apple Pay." ],
].each do |org, name, slug, description|
  Project.find_or_create_by!(organization: org, slug: slug) do |p|
    p.name = name
    p.description = description
    p.status = :active
  end
end

puts "Seeded: #{Organization.count} orgs, #{User.count} users, #{Membership.count} memberships, #{Project.count} projects"
