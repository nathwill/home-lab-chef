.PHONY: clean deps

clean:
	@rm -rf cookbooks

deps: cookbooks

cookbooks:
	@berks vendor $@ \
		--berksfile=site-cookbooks/home-lab/Berksfile \
		--except=local
