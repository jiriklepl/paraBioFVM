#include "agent_container.h"

#include <algorithm>

#include "agent.h"
#include "agent_container.h"

using namespace biofvm;

agent_container::agent_container(microenvironment& m) : data_(m) {}

void agent_container::add_agent(agent_ptr&& agent)
{
	agents_.emplace_back(std::move(agent));

	data_.add();
}

agent* agent_container::add_agent()
{
	add_agent(std::make_unique<agent>(next_agent_id_++, data_, data_.agents_count));

	return agents_.back().get();
}

void agent_container::remove_agent(agent_id_t id)
{
	auto it = std::find_if(agents_.begin(), agents_.end(), [id](const agent_ptr& a) { return a->id == id; });

	remove_agent(*it);
}

index_t agent_container::find_agent_index(const agent& agent) const { return agent.index_; }

void agent_container::remove_agent(agent_ptr& agent)
{
	index_t index_to_remove = find_agent_index(*agent);

	agents_.back()->index_ = index_to_remove;

	std::swap(agents_[index_to_remove], agents_.back());

	agents_.resize(agents_.size() - 1);

	data_.remove(index_to_remove);
}

const agent_data& agent_container::data() const { return data_; }

const std::vector<agent_ptr>& agent_container::agents() const { return agents_; }
